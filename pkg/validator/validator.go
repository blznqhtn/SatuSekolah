package validator

import "github.com/go-playground/validator/v10"

type GoPlaygroundValidator struct {
	validator *validator.Validate
}

func NewValidator() *GoPlaygroundValidator {
	return &GoPlaygroundValidator{
		validator: validator.New(),
	}
}

func (v *GoPlaygroundValidator) Validate(data interface{}) error {
	return v.validator.Struct(data)
}