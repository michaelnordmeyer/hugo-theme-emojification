![Hugo Theme Emojification](https://raw.githubusercontent.com/michaelnordmeyer/hugo-theme-emojification/main/repo-card.png)

# 🤩 Hugo Theme Emojification 🤩

A simple and minimal single-author theme with configurable big emoji as the header link, and configurable background colors, which can be chosen for each post or page.

[Demo site with examples](https://hugo-theme-emojification.michaelnordmeyer.com/)

The demo site has useful samples and shows many different color and emoji combinations and index page styles. Features, manuals, and sample colors are created as posts. [I run a muted version of the theme using `grey` as the main color on my own site](https://michaelnordmeyer.com/).

## Compatibility

Compatible with Hugo >= 0.158.0.

## Limited, But Useful Features

- Clean, minimalist design
  - Single-column
  - Single-author
  - No visible authors or categories on posts or pages
  - No header, footer, or menu
  - No pagination for the home page or any other index page to effectively be the archive and allow for searching all titles in-browser
  - System fonts without the dependence on possibly tracking third-parties
- Posts
- Pages
- Fancy category and tag pages
- Styled redirection and error pages
- Built-in Atom feed and sitemap.xml creation without category and tag pages so they don't compete on search engine result pages with post content
- Theme-color-matching favicons
- Optional colorful index pages
- Header images
- Optional descriptions or excerpts in feeds, SEO tags, and on category and home pages
- Content warnings for embedded videos
- Hidden semantic info for embedding and SEO like [Open Graph](https://ogp.me/), [JSON-LD](https://json-ld.org/), and inline [Microdata](https://en.wikipedia.org/wiki/Microdata_(HTML))
- Minimal build and load times
- Custom header and footer to add snippets

## Additional Features

Some features cannot be applied automatically due to how Hugo integrates themes. They have to be copied manually to your site’s root directory and are included in the `exampleSite`.

- Category settings from `data/categories.yml`
- Custom error pages from directory `errors`
- Settings from `hugo.toml`
- Draft, build, and deploy support via `Makefile`, including creating a UUID for posts

Only the category settings and custom error pages need to be edited, if you want to (category name, color, emoji, title, permalink, maybe extra textual content).

## Configuration

Read the [demo site](https://hugo-theme-emojification.michaelnordmeyer.com/) to learn about more options.

The assets have to be in `themes/hugo-theme-emojification/assets/assets`, because I want to have all my assets in `/assets/` on my server, and not in separate directories. This makes it easier to distinguish between site resources and content. The same goes for the `assets` directory in the blog's source directory, which needs to have its assets in `assets/assets`.

### Category Pages and Feeds

This theme creates an Atom feed instead of a RSS feed. Atom is still the much nicer, more modern and complete format like it was in 2009, when it was released.

Categories are declared in a post’s front matter and have to match the corresponding category in `data/categories.yml`, which is case-sensitive. This is necessary for displaying the proper category emoji and to have proper back-linking from posts belonging to a category to its category page. `data/categories.yml` allows to add front matter keys to the category’s index page and to add an introduction, which is displayed before the category list. Any introduction containing Markdown will have it translated to HTML.

Used categories have to be linked manually, because there is no menu.

Feeds for categories are automatically linked on the bottom of index pages and are embedded in the HTML page’s `<head>`.

The icons for the taxonomy pages like `/categories/` or `/tags/` are configured in `data/taxonomies.yml`. The keys work like the ones from `data/categories.yml`.

### Header Image Support

A header image is displayed after the title on posts and pages, if `featured_image` is added to the file's YAML frontmatter.

```yaml
---
params:
  featured_image:
    path: images/sample-image.jpg
    alt: The description of the image
    title: The title of the image
---
```

This image is also used in `feed.xml` and SEO tags as the displayed image.

### Descriptions

The descriptions are declared in the post's YAML frontmatter:

```yaml
description: "A helpful description."
```

They should be limited to 160 characters, because some of the places where they are used are effectively limited in length. If no descriptions are declared, then page’s `summary` will be used. This is either the manual declared one or Hugo will create one automatically.

#### Enabling Descriptions on the Home Page

To display post descriptions on the home page, simply add the following to your `hugo.toml`:

```toml
[params]
  show_descriptions = true
```

### Favicons

There can be several favicons for a site running this theme, because it is possible to use different background colors, and the favicon should reflect the color theme. But there is also a site-wide favicon, which should reflect the style of the home page, and is used in the Atom feed.

Icons are embedded in webp pixel format for its wide support and best file size to image quality ratio. Because favicons are displayed in many 3rd-party apps, websites, and other places, a SVG or data-URL version wouldn't work for lack of support.

#### Customizing Favicons

Icons should be named `<color>.webp` without the preceding hash of a hex color, having a resolution of 180×180 pixels, and be located in `/static/assets/icons/`. [Theme-matching icons can be easily generated from Unicode glyphs](https://michaelnordmeyer.com/generating-favicons-from-unicode-glyphs), if custom colors are used.

Shell scripts for creating those icons are included in the directory `_tools`. As mentioned in the linked article above, for other fonts or glyphs it might need some positioning to adjust for the metrics of the used font. These scripts need the free `convert` from ImageMagick to create the webp icons.

Icons for the default theme colors are included in webp format.

### Remove Content from Search Engines

If some posts or pages should not appear in search engines, they can be removed from the `sitemap.xml`, which helps search engines to find content. Additionally, a hidden header disallowing the indexing is added to the content, which respectable search engines follow. Add this to the YAML frontmatter to achieve this:

```yaml
---
sitemap:
  disable: true
---
```

### Custom Header and Footer to Add Snippets

When put in the directory `layouts/_partials/`, `custom-header.html` and `custom-footer.html` allow to put custom snippets in it.

## Installation

To install `hugo-theme-emojification`, add the following to your `hugo.toml`:

```toml
theme = 'github.com/michaelnordmeyer/hugo-theme-emojification'
```

Make sure it's the only `theme` setting.

## Updating the Theme

To update the theme to newer versions, you have to execute `hugo mod get -u github.com/michaelnordmeyer/hugo-theme-emojification` in your blog's root directory every once in a while.

If you want to get a specific version of the theme, add `@v1.2.3` to the theme URL to use version 1.2.3.

Always make sure that the theme's minimum Hugo version is installed locally. You can find the theme's minimum version the theme's `theme.toml` in the setting `min_version`.
