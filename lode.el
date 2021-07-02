;;; lode.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Jeet Ray

;; Author: Jeet Ray <aiern@protonmail.com>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Put a description of the package here

;;; Code:

(require 'deino)
(require 'alloy)
(require 'dash)
(require 'meq)

;;;###autoload
(defmacro lode* (parent key func hint &rest keychain)
    (let* ((last-step (= (-count 'keywordp keychain) 1))

            (open-keychain (-partition-before-pred #'keywordp keychain))
            (current-keychain (car open-keychain))

            ;; (carkey (meq/keyword-to-symbol-name (pop keychain)))
            (carkey (meq/keyword-to-symbol-name (car current-keychain)))

            (last-name (concat (when parent (concat parent "/")) carkey))

            (deino-name (concat "lodestar/" last-name))

            (hs (> (length current-keychain) 1))
            (head-list (when hs (cdr current-keychain)))
            (default-settings '(:color blue))
            (settings-list (if hs (let* ((fhh (caar head-list)))
                            (if (or (keywordp fhh) (keymapp fhh))
                                (pop head-list)
                                default-settings)) default-settings))

            (deino-funk (intern (concat
                "defdeino"
                (when (fboundp (intern (concat deino-name "/body"))) "+"))))

            (last-list (if last-step `(,carkey ,func ,hint)
                `(,carkey ,func ,hint)
                ;; `(,(meq/keyword-to-symbol-name (car keychain))
                ;;     ,`(lode* ,last-name ,key ,func ,hint ,@keychain) :color blue)
                )))

        ;; Adapted From: https://github.com/abo-abo/deino/issues/164#issuecomment-136650511
        `(,deino-funk
            ,(intern deino-name)
            ,settings-list
            ,@head-list
            ,last-list
            ("`" nil "cancel"))))

;;;###autoload
(defmacro lodestar (key func hint &rest keychain) (interactive) `(lode* nil ,key ,func ,hint ,@keychain))

;; Adapted From: https://github.com/noctuid/general.el/blob/master/general.el#L2708
;;;###autoload
(defun use-package-handler/:lodestar (name _keyword arglists rest state)
"Use-package handler for :lodestar."
(use-package-concat
    (use-package-process-keywords name rest state)
    `(,@(mapcar (lambda (arglist) arglist `(lodestar ,@arglist)) arglists))))

;;;###autoload
(defalias 'use-package-autoloads/:lodestar #'use-package-autoloads/:ghook)
;;;###autoload
(defalias 'use-package-normalize/:lodestar #'use-package-normalize/:ghook)

;; Adapted From: https://github.com/noctuid/general.el/blob/master/general.el#L2554
(setq use-package-keywords
    ;; should go in the same location as :bind
    ;; adding to end may not cause problems, but see issue #22
    (cl-loop for item in use-package-keywords
                if (eq item :bind-keymap*)
                collect :bind-keymap* and
                collect :lodestar
                else
                ;; don't add duplicates
                unless (memq item '(:lodestar))
                collect item))

(provide 'lode)
;;; lode.el ends here
