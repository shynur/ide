;;; -*- no-byte-compile: t -*-

((auto-mode-alist . (("[~#]\\'" . (ignore t))
                     ("/.git/COMMIT_EDITMSG\\'" . diff-mode)
                     ("/[._]clang-format\\'" . yaml-ts-mode)
		     ("/CMakeLists\\.txt\\'" . cmake-ts-mode)
		     ("\\.go\\'" . go-ts-mode)
                     ("\\.ya?ml\\'" . yaml-ts-mode)
                     ("/[.]clangd\\'" . yaml-ts-mode)
                     ("\\.json\\'" . js-json-mode)  ; json-ts-mode 总是用 space 缩进, 没办法了.
                     ("\\.mjs\\'" . javascript-mode)
                     ))
 (nil . ((eval . (when (derived-mode-p 'text-mode 'prog-mode 'conf-mode)
                   (add-hook 'before-save-hook
                             #'delete-trailing-whitespace
                             nil "local")))
         (delete-trailing-lines . t)
         (require-final-newline . t)
         (sentence-end-double-space . t)

         (eval . (when buffer-file-name
                   (when (string-match-p
                           "\\`\\(LICENSE\\|License\\|license\\|COPYING\\)\\'"
                           (file-name-base buffer-file-name))
                     (setq-local buffer-read-only t))))

         (eval . (line-number-mode -1))
         (mode . display-line-numbers)
         (mode . column-number)

         (read-file-name-completion-ignore-case . t)

         (project-vc-merge-submodules . nil)

         (mode . auto-save)

         (auto-revert-verbose . t)
         (auto-revert-avoid-polling . t)
         ;;(eval . (when buffer-file-name
         ;;          (when (string-match-p "\\.log\\.txt\\'" buffer-file-name)
         ;;            (auto-revert-tail-mode))))

         (treesit-font-lock-level . 4)))
 (makefile-mode . ((whitespace-style . (face tabs))
                   (mode . whitespace)))
 (markdown-mode . ((markdown-fontify-code-blocks-natively . t)))
 (js-json-mode . ((indent-tabs-mode . t)))
 (js-mode . ((indent-tabs-mode . nil)
               (tab-width . 4)))
 (yaml-mode . ((indent-tabs-mode . nil)
               (tab-width . 2)))
 ("node_modules" . ((nil . ((eval . (when buffer-file-name
                              (setq-local buffer-read-only t)))))))
)
