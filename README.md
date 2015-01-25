# vim-partial

Partial plugin is a tool developed to help you break down your code into partials.

## Usage
Simply select some lines on Visual mode, hit `<leader>x`, enter the desired
partial location and the plugin will place the appropiate replacement.

Let me show you:

![vim-partial](https://cloud.githubusercontent.com/assets/24221/5893819/1eca7c62-a4f3-11e4-9df1-1ad372c1c604.gif)

> **Note:**
> Did you find this plugin useful? Please star it and
> [share](https://twitter.com/home?status=%23vimpartial%20-%20easily%20extract%20partials%20from%20your%20code%20with%20this%20%23vim%20plugin%0A%0Ahttps://github.com/jbgutierrez/vim-partial)
> with others.

## Configuration

You can tweak the behavior of Partial by setting a few variables in your
`vimrc` file.

### Default Mapping
The default mapping to extract a partial is `<leader>x`.
You can easy map it to other keys. For example:

``` vim
vmap <Leader>x :PartialExtract<cr>
```

### g:loaded_partial
Partial is loaded only once. Set this to 1 to force Partial to reload every
time its file is sourced.

### g:partial_templates
Common file extensions are supported (**Markup:** .dust, .erb, .haml, .slim -
**Stylesheet:** .css, .less, .sass, .scss) and you can widen this list by
declaring a dictionary like so:

``` vim
let g:partial_templates = {
      \   'ejs': '<% include %s %>',
      \   'hbs': '{{> %s }}'
      \ }
```

### g:partial_templates_roots
Partial works with a list of usual roots for keeping your templates.
If you happen to use an uncommon root folder you can extend this list
like so:

``` vim
let s:partial_templates_roots = [
      \ 'stylus',
      \ 'tmpls'
      \ ]
```

### g:partial_keep_position
Cursor stays on the same position after replacement. Set this to 0 if you want
to continue with the edition of the partial file.

### g:partial_use_splits
New windows for partials are closed after being created. Set
this to 1 if you want to keep the partial in a new window.

### g:partial_vertical_split
Partial uses horizontal splits. Set this to 1 if you prefer vertical splits.

### g:partial_create_dirs
Partial creates directories as required. Set this to 0 if you don't want
Partial to create new directories.

## Implementation details

After triggering `:PartialExtract` the editor will:

  * throw an error if the file type is not supported (you may want to expand this list!)
  * suggest a folder with the same name as the file you are working in (without extensions)
  * throw an error if the file exists (you can overcome this error by triggering `:PartialExtract!`)
  * ensure the file has the proper extension(s) and create intermediate directories as required
  * set partial path relative to the templates folder and dispose any preceding
    underscores on the partial name
  * save the partial content getting rid of unneeded leading spaces and tabs
  * make the replacement

Partial tries to set `suffixesadd` and `includeexpr` on
`BufEnter` to navigate to partials under the cursor with `gf`.

## Bugs

Please report any bugs you may find on the GitHub [issue tracker](http://github.com/jbgutierrez/partial.vim/issues).

## Contributing

Think you can make Partial better? Great!, contributions are always welcome.

Fork the [project](http://github.com/jbgutierrez/partial.vim) on GitHub and send a pull request.

## Credits

This isn't new. I've borrow the core idea from the following two plugins:

 * [vim-rails](https://github.com/tpope/vim-rails) - highly recommended
 * [rails-partial](https://github.com/wesf90/rails-partial) - sublime users

## License

Partial is licensed under the MIT license.
See http://opensource.org/licenses/MIT

Happy hacking!
