`company-bibtex` provides a backend for the
company-mode framework, enabling completion of bibtex keys in
modes used for prose writing.  This backend activates for citation
styles used by `pandoc-mode` (@), `latex-mode` (\cite{}), and
`org-mode` (ebib:).

# Initialization 

Load the package and add `company-bibtex` to `company-backends`:

```elisp
(require 'company-bibtex)
(add-to-list 'company-backends 'company-bibtex)
```

# Customization

`company-bibtex` reads from a bibliography file or files
specified in `company-bibtex-bibliography`:

```elisp
(setq company-bibtex-bibliography
	'("/home/cooluser/thesis/thesis1.bib"
	  "/home/cooluser/thesis/thesi2.bib"))
```
`company-bibtex-key-regex` is the regular expression for matching acceptable key names. Alphanumeric characters,
dashes (-), and underscores (_) are acceptable by default:
`company-bibtex-key-regex`:

```elisp
(setq company-bibtex-key-regex "[[:alnum:]+_]*")
```
