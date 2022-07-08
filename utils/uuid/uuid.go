package uuid

type Generator interface {
	NextID() (string error)
}
