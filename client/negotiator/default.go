package negotiator

import "encoding/json"

type jsonImpl struct{}

func (i *jsonImpl) Encode(v interface{}) ([]byte, error) {
	return json.Marshal(v)
}

func (i *jsonImpl) Decode(data []byte, v interface{}) error {
	return json.Unmarshal(data, v)
}

func (i *jsonImpl) Name() string {
	return "default"
}
