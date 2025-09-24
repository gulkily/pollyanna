# HTML Style Guide and Specification

This document defines the HTML style guide and specification for the Pollyanna codebase, based on analysis of existing templates in `default/template/html/`.

## Core Principles

### 1. Browser Compatibility
- Support for older browsers and limited environments
- Graceful degradation without modern JavaScript
- Use of legacy HTML constructs where appropriate
- Minimal dependencies on modern CSS features

### 2. Template-Based Architecture
- All HTML is generated through template files (`.template` extension)
- Variable substitution using `$variableName` syntax
- Template comments: `<!-- template_name.template -->` and `<!-- / template_name.template -->`
- Modular composition with nested template includes

### 3. Accessibility and Semantics
- Use semantic HTML elements (`<main>`, `<fieldset>`, `<label>`)
- Proper form labeling and structure
- Alternative text for images
- Keyboard navigation support

## Document Structure

### Basic HTML Document Template
```html
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="x-ua-compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>$title</title>
<style type="text/css">
<!--
$styleSheet
-->
</style>
</head>
<body>
$content
</body></html>
```

### Required Meta Tags
- `charset="utf-8"` - UTF-8 encoding declaration
- `http-equiv="x-ua-compatible" content="IE=edge"` - IE compatibility mode
- `viewport` with `width=device-width, initial-scale=1` - Mobile responsiveness
- Redundant `Content-Type` meta tag for older browser support

## HTML Element Usage

### Legacy Elements
- Use `<nobr>` for preventing line breaks when CSS `white-space: nowrap` isn't available
- Support `<font>` elements with `face` and `color` attributes for styling
- Include `<iframe>` elements with proper `name` and `id` attributes
- Use `<noscript>` blocks for graceful degradation

### Tables
- Use tables for tabular data and layout when appropriate
- Always include `cellspacing`, `cellpadding`, and `border` attributes explicitly
- Use `bgcolor` attribute for background colors (legacy compatibility)
- Table structure example:
```html
<table cellspacing=0 cellpadding=3 border=0 bgcolor="$colorWindow">
    <tr bgcolor="$rowBgColor">
        <td>$content</td>
    </tr>
</table>
```

### Forms
- Wrap forms in `<fieldset>` elements
- Use proper `method` and `action` attributes
- Include `id`, `name`, and `class` attributes on form elements
- Label form elements properly:
```html
<fieldset>
    <form action="/post.html" method=GET id=compose>
        <label for="comment">Write something here:</label><br>
        <textarea id=comment name=comment rows=9 cols=32>$initText</textarea>
        <input type=submit value="Send Now" name=addtext id=addtext>
    </form>
</fieldset>
```

### Images
- Always include `alt` attributes
- Use `lowsrc` attribute for progressive loading when available
- Apply responsive sizing:
```html
<img style="max-width: 100%" width="90%" src="$imageUrl" 
     lowsrc="$imageSmallUrl" alt="$imageAlt">
```

### Links and Navigation
- Use descriptive link text
- Include `title` attributes for additional context
- Use `target=_top` when breaking out of frames

## Styling Guidelines

### CSS Integration
- Embed CSS in `<style>` tags with HTML comment wrapping:
```html
<style type="text/css">
<!--
body { font-family: sans-serif; }
-->
</style>
```

### Class and ID Naming
- Use lowercase with underscores: `class=top_menu`, `id=maincontent`
- Semantic names over presentational: `class=timestamp` not `class=small_text`
- Consistent prefixes for related elements: `span_dialog_controls`, `prop_top`
- Context-specific classes: `class=beginner`, `class=advanced`, `class=admin`
- State-based classes: `class=body`, `class=titlebar`, `class=content`

### Inline Styles
- Use sparingly and only for dynamic values
- Acceptable for template-driven styling: `style="max-width: 100%"`
- Prefer external stylesheets for static styling

## Template Structure

### Template Comments
Every template file should start and end with identifying comments:
```html
<!-- template_name.template -->
<div>Template content here</div>
<!-- / template_name.template -->
```

### Variable Substitution
- Use `$variableName` syntax for all dynamic content
- Variables can be used in attributes, content, and CSS values
- Example: `<title>$title</title>`, `bgcolor="$colorWindow"`

### Modular Design
- Break complex layouts into smaller template files
- Use consistent naming patterns: `item/item.template`, `form/write/write.template`
- Group related templates in subdirectories

## Accessibility Requirements

### Form Accessibility
- Associate labels with form controls using `for` and `id` attributes
- Provide meaningful `title` attributes for additional context
- Use `autofocus` appropriately for primary actions

### Semantic Structure
- Use `<main>` for primary content areas
- Include anchor tags for skip navigation: `<A NAME=maincontent></A>`
- Use heading hierarchy appropriately

### Image Accessibility
- Provide descriptive `alt` text for all images
- Use empty `alt=""` for decorative images
- Include `height` and `width` attributes to prevent layout shift

## JavaScript Integration

### Progressive Enhancement
- Ensure functionality works without JavaScript
- Use unobtrusive JavaScript practices
- Wrap JavaScript in HTML comments for older browsers:
```html
<script language=javascript>
<!--
function myFunction() {
    // JavaScript code here
}
// -->
</script>
```

### NoScript Handling
- Use `<noscript>` tags to provide alternatives for non-JS users
- Include visual indicators for JavaScript-dependent features:
```html
<noscript>
    <p><b class=noscript>*</b> Some features may need <b>JavaScript</b>.</p>
</noscript>
<label>
    Show advanced controls<noscript><b>*</b></noscript>
</label>
```

### Event Handling
- Use semantic event handlers: `onclick="functionName(event)"`
- Check for element existence before manipulation: `if (window.functionName)`
- Provide fallbacks for disabled JavaScript
- Use defensive programming: `if (window.scrollTo) { window.scrollTo(0, 0); }`

### Script Injection Pattern
- Use template-based script injection for dynamic JavaScript:
```html
<script language=javascript><!--
$javascript
// -->
</script>
```

## Legacy Browser Support

### HTML Attributes
- Use quoted attribute values consistently
- Include all required attributes explicitly
- Use legacy attributes when modern alternatives aren't supported
- Support framesets for legacy applications: `<frameset border=0 cols="*,*">`
- Include `language=javascript` attribute for older browsers
- Use `<font>` tags when CSS support is limited

### CSS Compatibility
- Avoid modern CSS features that break in older browsers
- Use vendor prefixes for CSS3 features: `-webkit-calc()`, `-moz-calc()`
- Provide fallbacks for unsupported properties

### Doctype and Encoding
- Use simple `<html>` tag (not HTML5 doctype) for maximum compatibility
- Declare UTF-8 encoding in multiple ways for reliability

## Performance Considerations

### Resource Loading
- Use `lowsrc` attribute for progressive image loading
- Minimize external dependencies
- Inline critical CSS in template heads
- Implement prefetch links for common pages:
```html
<link rel="prefetch" href="/read.html"></link>
<link rel="prefetch" href="/write.html"></link>
```

### Template Efficiency
- Keep templates focused and lightweight
- Avoid deep nesting when possible
- Use efficient variable substitution patterns
- Single-line templates for simple components: `<tr><td><a href="$link">$labelName</a></td></tr>`

## Security Guidelines

### Input Sanitization
- All template variables should be sanitized before output
- Use proper escaping for HTML entities
- Validate all user-generated content

### Safe Defaults
- Use secure default attributes
- Avoid inline event handlers when possible
- Sanitize all dynamic URLs and paths

## User Experience Patterns

### Progressive Disclosure
- Use `class=beginner`, `class=advanced`, `class=admin` for progressive UI
- Provide explanatory text for complex features
- Include contextual help and hints

### Error and Status Pages
- Implement standardized error templates (401.template, 404.template)
- Use descriptive titles and helpful messaging
- Provide clear navigation options for recovery

### Interactive Elements
- Include proper JavaScript feature detection
- Use defensive programming patterns: `if (window.functionName)`
- Provide visual feedback for user actions

## File Organization

### Directory Structure
```
html/
├── page/           # Full page templates
├── form/           # Form-related templates
│   ├── write/      # Content writing forms
│   └── profile/    # User profile forms
├── item/           # Content item templates
│   └── container/  # Content type containers
├── widget/         # Reusable UI components
├── keyboard/       # Virtual keyboard templates
├── window/         # Window/dialog templates
├── vote/           # Voting system templates
├── frameset/       # Legacy frameset layouts
├── dialog/         # Modal and dialog templates
├── author/         # User profile templates
└── utils/          # Utility templates (script injection, etc.)
```

### Naming Conventions
- Use descriptive, hierarchical names
- Group related templates in subdirectories
- Use `.template` extension for template files, `.html` for complete pages
- Match directory structure to functional organization
- Include template identification comments in each file

### Template Size Guidelines
- Prefer single-purpose, focused templates
- Break complex layouts into smaller, reusable components
- Use wrapper templates for consistent page structure
- Keep individual templates under 100 lines when possible

This specification ensures consistency, accessibility, and compatibility across the Pollyanna HTML template system while maintaining support for a wide range of browsers and environments.