package test

import (
	"testing"

	"github.com/DATA-DOG/godog"
	bplustest "gitlab.intelligentb.com/devops/bplus/test"
	hellotest "github.com/MenaEnergyVentures/hello/test"
	carfueltest "github.com/MenaEnergyVentures/order-carfuel/test"
)

func TestMain(m *testing.M) {
	bplustest.BDD(m, FeatureContext)
}

func FeatureContext(s *godog.Suite) {
	carfueltest.FeatureContext(s)
	hellotest.FeatureContext(s)
}
