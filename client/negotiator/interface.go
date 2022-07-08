package negotiator

type Negotiator interface {
	Name() string
	Decoder
	Encoder
}

type Decoder interface {
	Decode(data []byte, v interface{}) error
}

type Encoder interface {
	Encode(v interface{}) ([]byte, error)
}
