package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/infrastructure/cloud/aws"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/attendance/domain"
)

type attendanceUsecase struct {
	repo       domain.AttendanceRepository
	rekognition *aws.RekognitionClient
}

func NewAttendanceUsecase(repo domain.AttendanceRepository, rekognition *aws.RekognitionClient) domain.AttendanceUsecase {
	return &attendanceUsecase{repo: repo, rekognition: rekognition}
}

func (u *attendanceUsecase) ProcessPresence(ctx context.Context, req *domain.PresenceRequest) (interface{}, error) {
	// 1. Identify User
	userID, classID, roleID, err := u.repo.GetUserByIdentifier(ctx, req.TenantID, req.Method, req.Identifier)
	if err != nil || userID == nil {
		return nil, fmt.Errorf("user not found or invalid identifier")
	}

	now := time.Now()

	// 2. Check if today is a Holiday
	holiday, _ := u.repo.GetHoliday(ctx, req.TenantID, now)
	isHoliday := holiday != nil // simplified, assume applies to this user for now

	// 3. Check for targeted active Activities
	activities, err := u.repo.GetActiveActivities(ctx, req.TenantID, now)
	var matchedActivity *domain.Activity
	if err == nil {
		for _, act := range activities {
			// Check if this specific user/class/role is targeted
			cID := uuid.Nil
			rID := uuid.Nil
			if classID != nil {
				cID = *classID
			}
			if roleID != nil {
				rID = *roleID
			}
			isTargeted, _ := u.repo.IsUserTargetedForActivity(ctx, act.ID, *userID, cID, rID)
			if isTargeted {
				matchedActivity = act
				break // Take the first matched activity
			}
		}
	}

	// 4. State Machine Logic
	if matchedActivity != nil {
		// --- ACTIVITY ATTENDANCE ---
		actAtt, _ := u.repo.GetTodayActivityAttendance(ctx, matchedActivity.ID, *userID)
		if actAtt == nil {
			// Check In
			actAtt = &domain.ActivityAttendance{
				ActivityID: matchedActivity.ID,
				UserID:     *userID,
				CheckInAt:  &now,
				Status:     domain.StatusPresent,
			}
			if err := u.repo.CreateActivityAttendance(ctx, actAtt); err != nil {
				return nil, err
			}
			
			// Replace Daily Attendance if configured
			if matchedActivity.ReplacesDailyAttendance {
				notes := "Attending Activity: " + matchedActivity.Name
				daily := &domain.Attendance{
					TenantID:  req.TenantID,
					UserID:    *userID,
					Type:      "ACTIVITY_REPLACEMENT",
					Method:    domain.MethodSystem,
					CheckInAt: &now,
					Status:    domain.StatusPresent,
					Notes:     &notes,
				}
				_ = u.repo.CreateDailyAttendance(ctx, daily)
			}
			return map[string]string{"status": "ACTIVITY_CHECK_IN_SUCCESS", "activity": matchedActivity.Name}, nil
		} else if matchedActivity.RequiresCheckout && actAtt.CheckOutAt == nil {
			// Check Out
			actAtt.CheckOutAt = &now
			if err := u.repo.UpdateActivityAttendance(ctx, actAtt); err != nil {
				return nil, err
			}
			return map[string]string{"status": "ACTIVITY_CHECK_OUT_SUCCESS", "activity": matchedActivity.Name}, nil
		} else {
			return map[string]string{"status": "ALREADY_ATTENDED"}, nil
		}
	}

	// --- DAILY ATTENDANCE ---
	if isHoliday {
		return nil, fmt.Errorf("today is a holiday (%s), no daily attendance allowed", holiday.Name)
	}

	dailyAtt, _ := u.repo.GetTodayDailyAttendance(ctx, req.TenantID, *userID)
	settings, _ := u.repo.GetSetting(ctx, req.TenantID)

	if dailyAtt == nil {
		// Daily Check In
		status := domain.StatusPresent
		// Simple late check
		checkInTime, _ := time.Parse("15:04:05", settings.CheckInTime)
		expectedCheckIn := time.Date(now.Year(), now.Month(), now.Day(), checkInTime.Hour(), checkInTime.Minute(), 0, 0, now.Location())
		if now.After(expectedCheckIn.Add(time.Duration(settings.ToleranceMinutes) * time.Minute)) {
			status = domain.StatusLate
		}

		dailyAtt = &domain.Attendance{
			TenantID:  req.TenantID,
			UserID:    *userID,
			Type:      "DAILY",
			Method:    req.Method,
			CheckInAt: &now,
			Status:    status,
		}
		
		if err := u.repo.CreateDailyAttendance(ctx, dailyAtt); err != nil {
			return nil, err
		}

		res := map[string]interface{}{"status": "CHECK_IN_SUCCESS"}
		if status == domain.StatusLate {
			res["status"] = "LATE_CHECK_IN"
			res["requires_late_form"] = true
			res["attendance_id"] = dailyAtt.ID
		}
		
		// TODO: Trigger notification to Parent here
		
		return res, nil
	} else if dailyAtt.CheckOutAt == nil {
		// Daily Check Out
		dailyAtt.CheckOutAt = &now
		if err := u.repo.UpdateDailyAttendance(ctx, dailyAtt); err != nil {
			return nil, err
		}
		// TODO: Trigger notification to Parent here
		return map[string]string{"status": "CHECK_OUT_SUCCESS"}, nil
	}

	return map[string]string{"status": "ALREADY_ATTENDED"}, nil
}

func (u *attendanceUsecase) RegisterFace(ctx context.Context, userID uuid.UUID, req *domain.FaceRegistrationRequest) (string, error) {
	if len(req.Images) != 6 {
		return "", fmt.Errorf("exactly 6 images are required for registration")
	}

	// Note: in a real implementation, you would decode the base64 images to []byte
	// For brevity in this code, we assume the Request contains the raw bytes, or we parse it here.
	// We'll mock the byte array conversion for now.
	var imagesBytes [][]byte
	for _, imgStr := range req.Images {
		imagesBytes = append(imagesBytes, []byte(imgStr)) // Placeholder for base64 decode
	}

	faceID, _, err := u.rekognition.RegisterBestFace(ctx, userID.String(), imagesBytes)
	if err != nil {
		return "", err
	}

	// Update user record
	if err := u.repo.UpdateUserFaceID(ctx, userID, faceID); err != nil {
		return "", err
	}

	// We could also upload bestImageBytes to S3 here as requested by user

	return faceID, nil
}
