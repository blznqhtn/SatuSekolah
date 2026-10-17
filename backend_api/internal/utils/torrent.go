package utils

import (
	"path/filepath"

	"github.com/anacrolix/torrent/bencode"
	"github.com/anacrolix/torrent/metainfo"
)

// GenerateTorrentMetadata generates torrent infohash and magnet link for WebTorrent
func GenerateTorrentMetadata(localFilePath, webSeedURL string, trackerURL string) (string, string, error) {
	mi := metainfo.MetaInfo{
		AnnounceList: [][]string{
			{trackerURL},
		},
		CreatedBy: "Satu Sekolah Backend",
	}

	info := metainfo.Info{
		PieceLength: 256 * 1024, // 256KB pieces
		Name:        filepath.Base(localFilePath),
	}

	if err := info.BuildFromFilePath(localFilePath); err != nil {
		return "", "", err
	}

	infoBytes, err := bencode.Marshal(info)
	if err != nil {
		return "", "", err
	}
	mi.InfoBytes = infoBytes
	mi.UrlList = []string{webSeedURL}

	infoHash := mi.HashInfoBytes()
	infoHashHex := infoHash.HexString()

	magnetParams := mi.Magnet(&infoHash, &info)
	magnetLink := magnetParams.String()

	return infoHashHex, magnetLink, nil
}
