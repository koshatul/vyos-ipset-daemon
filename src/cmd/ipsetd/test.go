package main

import (
	"strconv"
	"strings"

	"github.com/koshatul/vyos-ipset-daemon/src/ipset"
	"github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
)

var cmdTest = &cobra.Command{
	Use:     "test [ipaddress...N]",
	Example: "test 127.0.0.1 172.16.0.1:60",
	Short:   "Test Command",
	Run:     testCommand,
}

func init() {
	rootCmd.AddCommand(cmdTest)
}

func testCommand(cmd *cobra.Command, args []string) {
	logrus.Debug("testCommand():start")

	testIPSet, err := ipset.New("test", "hash:ip", &ipset.Params{})
	if err != nil {
		logrus.Panic(err)
	}
	testIPSet.Add("8.8.4.4", 0)
	for _, arg := range args {
		sparg := strings.SplitN(arg, ":", 2)
		timeout := int64(0)
		if len(sparg) == 2 {
			timeout, err = strconv.ParseInt(sparg[1], 0, 64)
		}
		testIPSet.Add(sparg[0], int(timeout))
	}

	ipList, err := testIPSet.List()
	if err != nil {
		logrus.Panic(err)
	}
	logrus.Infof("Entries: %d", len(ipList))
	for _, ipAddr := range ipList {
		logrus.Infof("IP Address: %s", ipAddr)
	}

	logrus.Debug("testCommand():end")
}
