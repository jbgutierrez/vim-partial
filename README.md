# vim-partial

Partial plugin is a tool developed to help you break down your code in partials.

## Usage
Simply select some lines on Visual mode, hit `<leader>x`, enter the desired
partial location and the plugin will place the appropiate replacement.

## Configuration

You can tweak the behavior of Partial by setting a few variables in your
`vimrc` file.

### Default Mapping
The default mapping to extract a partial is `<leader>x`.
You can easy map it to other keys. For example:

``` vim
vmap <Leader>P :PartialExtract<cr>
```

### g:loaded_partial
Set this to 1 to force Partial to reload every time its file is sourced.

Options: 0 or 1
Default: 0 (Partial is loaded only once)

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

### g:partial_keep_position
Set this to 0 if you want to continue with the edition of the partial file

Options: 0 or 1
Default: 1 (Cursor stays on the same position after replacement)

## Implementation details

After triggering `:PartialExtract` the editor will:

  * throw an error if the file type is not supoorted (you may want to expand this list!)
  * suggest a folder with the same name as the file you are working in (without extensions)
  * throw an error if the file exists (you can overcome this error by triggering `:PartialExtract!`)
  * ensure the file has the proper extension(s) and create intermediate directories as required
  * dispose any preceding underscores on the partial name
  * set partial path relative to the current directory name or views/templates ancestor folder
  * save the partial content getting rid of unneeded leading spaces
  * make the replacement

## Bugs

Please report any bugs you may find on the GitHub [issue tracker](http://github.com/jbgutierrez/partial.vim/issues).

## Contributing

Think you can make Partial better?  Awesome.  New contributors are always
welcome. Fork the [project](http://github.com/jbgutierrez/partial.vim) on GitHub and send a pull request.

## Credits

This isn't new. I've borrow the core idea from the following two plugins:

 * [vim-rails](https://github.com/tpope/vim-rails) - highly recommended
 * [rails-partial](https://github.com/wesf90/rails-partial) - sublime users

## License

Partial is licensed under the MIT license.
See http://opensource.org/licenses/MIT

Enjoy!
