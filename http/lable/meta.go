package lable

const (
	// Resource key name
	Resource = "resource"

	// Auth 控制是否开启认证
	Auth = "auth"

	// Permission 控制是否开启权限判定
	Permission = "permission"

	// Allow 控制允许的角色
	Allow = "allow"

	//Audit 控制是否开启审计
	Audit = "audit"
)

const (
	Enable  = true
	Disable = false
)

type Meta map[string]interface{}

func (m Meta) Resource() string {
	if v, ok := m[Resource]; ok {
		return v.(string)
	}

	return ""
}

func (m Meta) Action() string {
	if v, ok := m[Action]; ok {
		return v.(string)
	}

	return ""
}

func (m Meta) AuthEnable() bool {
	if v, ok := m[Auth]; ok {
		return v.(bool)
	}
	return false
}

func (m Meta) PermissionEnable() bool {
	if v, ok := m[Permission]; ok {
		return v.(bool)
	}
	return false
}

func (m Meta) AuditEnable() bool {
	if v, ok := m[Audit]; ok {
		return v.(bool)
	}
	return false
}

func (m Meta) Allow() []string {
	if v, ok := m[Allow]; ok {
		return v.([]string)
	}
	return []string{}
}
