# Goto File for Python

This is a simple utility to improve vim's standard goto file `gf` mapping in python. It can find most things, but not all. 

It iterates through python's `sys.path` and looks for modules where one would typically expect to find them.

For example:

- `gf` on `os` finds `os.py`.
- `gf` on `email.base64mime` finds `email/base64mime.py`.
- `gf` on `sqlite3` finds `sqlite3/__init__.py`.

It does not find more complicated relationships like `os.path`.

I have a solution to find things like `os.path`, but the implementation could be considered unsafe. It would involve attempting to `import` it, and so depending on what one tries to find, it could be dangerous as the code would in effect be evaluated.
