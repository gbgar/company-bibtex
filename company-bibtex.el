;;; company-bibtex.el --- Company completion for bibtex keys
;;; Commentary:
;;; Code:
(require 'cl-lib)
(require 'parsebib)

(defgroup company-bibtex nil
  "Company backend for BibTeX bibliography keys."
  :group 'company)

(defcustom company-bibtex-bibliography nil
  "List of bibtex files used for gathering completions."
  :group 'company-bibtex
  :type '(choice (file :must-match t)
		 (repeat (file :must-match t))))

(defcustom company-bibtex-key-regex "[[:alnum:]_-]*"
  "Regex matching bibtex key names, excluding mode-specific prefixes."
  :group 'company-bibtex
  :type 'regexp)

(defconst company-bibtex-pandoc-citation-regex
  (concat "-?@" company-bibtex-key-regex)
  "Regex for pandoc citation prefix.")

(defconst company-bibtex-latex-citation-regex
  (concat "\\\\cite{" company-bibtex-key-regex)
  "Regex for latex citation prefix.")

(defconst company-bibtex-org-citation-regex
  (concat "ebib:" company-bibtex-key-regex)
  "Regex for org citation prefix.")

(defun company-bibtex-candidates (prefix)
  "Parse .bib file for candidates and return list of keys.
Prepend the appropriate part of PREFIX to each item."
  (with-temp-buffer
    (mapc #'insert-file-contents
	  (if (listp company-bibtex-bibliography)
	      company-bibtex-bibliography
	    (list company-bibtex-bibliography)))
    (string-match "\\(-?@\\|\\\\cite{\\|ebib:\\)[-_[:alnum:]]*" prefix)
    (let ((prefixprefix (match-string-no-properties 1 prefix)))
      (progn (mapcar (function (lambda (l) (concat prefixprefix l)))
		     (mapcar 'cdr
			     (mapcar (function (lambda (x) (assoc "=key=" x)))
				     (company-bibtex-parse-bibliography))))))))

(defun company-bibtex-parse-bibliography ()
  "Parse BibTeX entries listed in the current buffer.

Return a list of entry keys in the order in which the entries
appeared in the BibTeX files."
  (goto-char (point-min))
  (cl-loop
   for entry-type = (parsebib-find-next-item)
   while entry-type
   unless (member-ignore-case entry-type '("preamble" "string" "comment"))
   collect (-map (lambda (it)
		   (cons (downcase (car it)) (cdr it)))
		 (parsebib-read-entry entry-type))))

;;;###autoload
(defun company-bibtex-backend (command &optional arg &rest ignored)
  "`company-mode' completion backend for bibtex key completion.

This backend activates for citation styles used by `pandoc-mode' (@),
`latex-mode' (\cite{}), and `org-mode' (ebib:), and reads from a
bibliography file or files specified in `company-bibtex-bibliography'.
COMMAND, ARG, and IGNORED are used by `company-mode'."

  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-bibtex-backend))
    (prefix (and (or (derived-mode-p 'markdown-mode)
		     (derived-mode-p 'latex-mode)
		     (derived-mode-p 'org-mode))
		 (or (company-grab company-bibtex-pandoc-citation-regex)
		     (company-grab company-bibtex-latex-citation-regex)
		     (company-grab company-bibtex-org-citation-regex))))
    (candidates
     (remove-if-not
      (lambda (c) (string-prefix-p arg c))
      (company-bibtex-candidates arg)))
    (duplicates t)))

(provide 'company-bibtex)

;;; company-bibtex.el ends here
