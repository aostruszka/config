" DXL is nearly like C

runtime! ftplugin/c.vim ftplugin/c_*.vim ftplugin/c/*.vim

setlocal syntax=c sw=2 cino= fdm=indent tw=80

setlocal path+=C:\Program\\\ Files\Telelogic\DOORS\\\ 6\lib\dxl\**

" Win32 can filter files in the browse dialog
if has("gui_win32") && !exists("b:browsefilter")
  let b:browsefilter = "DXL Source Files (*.dxl *.inc)\t*.dxl;*.inc\n" .
	\ "All Files (*.*)\t*.*\n"
endif
