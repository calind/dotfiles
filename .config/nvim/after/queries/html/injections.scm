;; extends

; AlpineJS attributes
(attribute
  (attribute_name) @alpine.directive
    (#match? @alpine.directive "^\%(\%(x-\(ref|model|transition\)\@!\)|[:@]\)")
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#set! injection.language "javascript")
)

; HTMX attributes
(attribute
  (attribute_name) @htmx.directive
    (#match? @htmx.directive "^hx-on")
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#set! injection.language "javascript")
)
