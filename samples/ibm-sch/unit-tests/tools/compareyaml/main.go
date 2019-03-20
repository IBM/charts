package main

import (
  "flag"
  "fmt"
  "gopkg.in/yaml.v2"
  "io/ioutil"
  "os"
  "reflect"
)

func main() {
  var debug bool
  var expectedFile string
  var actualFile string
  flag.BoolVar(&debug, "debug", false, "Print additional messages during execution.")
  flag.StringVar(&expectedFile, "expected", "", "The expected file to compare")
  flag.StringVar(&actualFile, "actual", "", "The actual file to compare")
  flag.Parse()

  if expectedFile == "" {
    printErr("No file specified for expected")
    os.Exit(1)
  } else if actualFile == "" {
    printErr("No file specified for actual")
    os.Exit(1)
  }

  //args := os.Args[1:]
  //if len(args) < 2 {
  //  printErr(fmt.Sprintf("Error, not enough parameters specified. Expected: 2, Received: %d", len(args)))
  //  return
  //}
  //expectedFile := args[0]
  //actualFile := args[1]

  //fmt.Printf("", *boolPtr)

  if debug {
    fmt.Printf("Comparing %s to %s\n", expectedFile, actualFile)
  }

  expectedFileYamlBytes, err := ioutil.ReadFile(expectedFile)
  if err != nil {
    printErr(fmt.Sprintf("Error reading %s: %s", expectedFile, err))
    os.Exit(2)
  }
  actualFileYamlBytes, err := ioutil.ReadFile(actualFile)
  if err != nil {
    printErr(fmt.Sprintf("Error reading %s: %s", actualFile, err))
    os.Exit(2)
  }

  var expectedFileYaml map[string]interface{}
  var actualFileYaml map[string]interface{}
	err = yaml.Unmarshal(expectedFileYamlBytes, &expectedFileYaml)
  if err != nil {
    printErr(fmt.Sprintf("Error parsing yaml for file %s: %s", expectedFile, err))
    os.Exit(3)
  }
  err = yaml.Unmarshal(actualFileYamlBytes, &actualFileYaml)
  if err != nil {
    printErr(fmt.Sprintf("Error parsing yaml for file %s: %s", actualFile, err))
    os.Exit(3)
  }

  if debug {
    fmt.Println("expected file contents: ", expectedFileYaml)
    fmt.Println("actual file contents:   ", actualFileYaml)
  }

  if !reflect.DeepEqual(expectedFileYaml, actualFileYaml){
    fmt.Printf("Error: %s does not match the expected value in %s\n", expectedFile, actualFile)
    os.Exit(4)
  } else {
    fmt.Printf("The two files are equal!\n")
  }

}

func printErr (err string){
  output := fmt.Sprintf(`%s
compareyaml usage:
  -actual string
    	The actual file to compare
  -debug
    	Print additional messages during execution.
  -expected string
    	The expected file to compare`, err)
  fmt.Printf(output)
}
