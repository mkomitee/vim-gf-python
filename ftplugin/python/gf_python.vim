" Copyright 2011 Michael Komitee. All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"
" 1. Redistributions of source code must retain the above copyright notice,
" this list of conditions and the following disclaimer.
"
" 2. Redistributions in binary form must reproduce the above copyright
" notice, this list of conditions and the following disclaimer in the
" documentation and/or other materials provided with the distribution.
"
" THIS SOFTWARE IS PROVIDED BY MICHAEL KOMITEE ``AS IS'' AND ANY EXPRESS OR
" IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
" OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
" NO EVENT SHALL MICHAEl KOMITEE OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
" INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
" (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
" LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
" OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
" DAMAGE.
"
" The views and conclusions contained in the software and documentation are
" those of the authors and should not be interpreted as representing official
" policies, either expressed or implied, of Michael Komitee.

if exists("g:loaded_gf_python")
    finish
endif

let g:loaded_gf_python = 1

if !has('python')
    echoerr "Error: the gf_python.vim plugin requires Vim to be compiled with +python"
    finish
endif

python << EOF

from __future__ import print_function, unicode_literals

import imp
import os
import re
import vim


def gf_python_find_module(module, path=None):
    spec = module.lstrip('.')
    relative = len(module) - len(spec)
    parts = spec.split('.')

    if relative:
        path = os.path.join(path, *(['.'] + ['..']*(relative-1)))
    
    if len(parts) == 1:
        if path:
            fh, filename, (suffix, mode, type_) = imp.find_module(spec, [path])
        else:
            fh, filename, (suffix, mode, type_) = imp.find_module(spec)
        try:
            if type_ == imp.PKG_DIRECTORY:
                return os.path.join(filename, '__init__.py')
            elif type_ == imp.PY_COMPILED:
                return filename.rstrip('c')
            elif type_ == imp.PY_SOURCE:
                return filename
            else:
                raise Exception()
        finally:
            if fh:
                fh.close()
    else:
        if path:
            fh, filename, (suffix, mode, type_) = imp.find_module(parts[0], [path])
        else:
            fh, filename, (suffix, mode, type_) = imp.find_module(parts[0])
        try:
            return gf_python_find_module('.'.join(parts[1:]), filename)
        finally:
            if fh:
                fh.close()


def python_goto_file():
    module = vim.eval('expand("<cfile>")')
    buf_pwd = os.path.split(vim.eval('expand("%")'))[0]
    if buf_pwd.startswith('/'):
        path = buf_pwd
    else:
        vim_pwd = vim.eval('expand("$PWD")')
        path = os.path.join(vim_pwd, buf_pwd)
    try:
        if module.startswith('.'):
            filename = gf_python_find_module(module, path)
        else:
            filename = gf_python_find_module(module)
    except:
        print('E447: Can\'t find module "%s"' % module, file=sys.stderr)
    else:
        vim.command('edit %s' % filename)
    return
EOF

nnoremap <buffer> gf :python python_goto_file()<cr>

