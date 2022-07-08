package validator

import (
	"fmt"
	zhc "github.com/go-playground/locales/zh"
	ut "github.com/go-playground/universal-translator"
	"github.com/go-playground/validator"
	zht "github.com/go-playground/validator/v10/translations/zh"
)

var (
	v     *validator.Validate
	trans ut.Translator
)

//Instance 全局校验器
func Instance() *validator.Validate {
	return v
}

func Init() error {
	zh := zhc.New()
	uni := ut.New(zh, zh)
	tr, ok := uni.GetTranslator("zh")
	if !ok {
		return fmt.Errorf("zh not found")
	}

	trans = tr
	validate := validator.New()

	err := zht.RegisterDefaultTranslations(validate, trans)
	if err != nil {
		return err
	}

	v = validate
	return nil
}

func Validate(target interface{}) error {
	if v == nil {
		return fmt.Errorf("validator not init")
	}

	err := v.Struct(target)
	errs, ok := err.(validator.ValidationErrors)
	if !ok {
		return err
	}

	fe := errs.Translate(trans)
	fmt.Println(fe)
	return nil
}
