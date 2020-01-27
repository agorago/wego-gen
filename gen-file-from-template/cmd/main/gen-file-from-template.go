package main

import (
	"fmt"
	"log"
	"os"
	"text/template"

	"github.com/MenaEnergyVentures/code-gen/util"
)



func main() {
	if len(os.Args) != 4 {
		log.Fatalf("Usage: %s interface-file url template-file", os.Args[0])
		os.Exit(0)
	}
	templateFile := os.Args[3]
	processAndPrint(util.ParseService(),templateFile)
}

func processAndPrint(sdet util.Servicedetail,templateFile string) {
	tpl, err := template.ParseFiles(templateFile)
	if err != nil {
		fmt.Printf("uh oh problem with template.err = %s\n", err.Error())
		return
	}

	tpl.Execute(os.Stdout, sdet)
}

