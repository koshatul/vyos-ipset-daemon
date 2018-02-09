package main

import (
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

func configDefaults() {
}

func configInit() {
	if viper.GetBool("debug") {
		logrus.SetLevel(logrus.DebugLevel)
	} else {
		logrus.SetLevel(logrus.InfoLevel)
	}

	// logrus.Debug("+++configInit()")
	viper.SetConfigName("ipsetd")
	viper.SetConfigType("toml")
	viper.AddConfigPath("/etc/ipset")
	viper.AddConfigPath("/usr/local/ipset/etc")
	viper.AddConfigPath("$HOME/.config")
	viper.AddConfigPath("/run/secrets")
	viper.AddConfigPath(".")

	configDefaults()

	viper.ReadInConfig()

}
