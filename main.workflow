workflow "generate pdf" {
  resolves = "build"
}

action "build" {
  uses = "docker://ivotron/pandoc@2.3.1"
  args = [
    "--output=out/paper.pdf",
    "--template=pandoc/template.latex",
    "--csl=pandoc/ieee.csl",
    "--highlight-style=tango",
    "--bibliography=refs.bib",
    "--filter=pandoc-tabularize.py",
    "--filter=pandoc-crossref",
    "--filter=pandoc-citeproc",
    "--metadata", "acmart=true",
    "--metadata", "documentclass=acmart",
    "--metadata", "classoption=sigconf",
    "--metadata", "natbib=false",
    "--metadata", "usedefaultspacing=true",
    "--metadata", "numbersections=true",
    "--metadata", "secPrefix=section",
    "--standalone",
    "--smart"
  ]
}
