workflow "generate pdf" {
  resolves = "build"
}

action "build" {
  uses = "docker://ivotron/pandoc:2.3.1"
  args = [
    "--standalone",
    "--from=markdown+smart",
    "--output=paper.pdf",
    "--highlight-style=tango",
    "--bibliography=refs.bib",
    "--filter=pandoc/pandoc-tabularize.py",
    "--filter=pandoc-crossref",
    "--filter=pandoc-citeproc",
    "--metadata", "natbib=false",
    "--metadata", "numbersections=true",
    "--metadata", "secPrefix=section",
    "paper.md"
  ]
}
