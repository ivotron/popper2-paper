workflow "generate pdf" {
  resolves = "build"
}

action "build" {
  uses = "docker://ivotron/pandoc:2.3.1"
  runs = [
    "pandoc/entrypoint.sh",
    "--standalone",
    "--from=markdown+smart",
    "--template=pandoc/template.latex",
    "--csl=pandoc/IEEE.csl",
    "--output=paper.pdf",
    "--highlight-style=tango",
    "--bibliography=refs.bib",
    "--metadata=IEEETran:true",
    "--metadata=documentclass:IEEETran",
    "--metadata=classoption:conference",
    "--metadata=natbib:false",
    "--metadata=usedefaultspacing:false",
    "--metadata=numbersections:true",
    "--metadata=secPrefix:section",
    "--filter=pandoc/pandoc-tabularize.py",
    "--filter=pandoc-crossref",
    "--filter=pandoc-citeproc",
    "paper.md"
  ]
}
