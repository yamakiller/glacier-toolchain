package service

//InitAllService 初始化所有服务
func InitAllService() error {
	// 优先初始化内部app
	for _, api := range internalServices {
		if err := api.Config(); err != nil {
			return err
		}
	}

	for _, api := range grpcServices {
		if err := api.Config(); err != nil {
			return err
		}
	}

	for _, api := range restfulServices {
		if err := api.Config(); err != nil {
			return err
		}
	}

	for _, api := range httpServices {
		if err := api.Config(); err != nil {
			return err
		}
	}

	for _, api := range ginServices {
		if err := api.Config(); err != nil {
			return err
		}
	}

	return nil
}
