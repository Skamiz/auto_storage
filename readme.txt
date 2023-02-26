Auto Storage
============
Quickly sorts your inventory to nearby storage containers
if they contain at least one of the item you want to store.

Also provides a configuration menu in which you can 'lock' inventory slots.
Items in locked slots never get sorted away.

Usage
-----
Functionality can be accessed at the press of a button through sfinv
or as a backup through chat commands:
/auto_storage config - configure which inventory slots can be stored
/auto_storage store - automatically store items to nearby containers

Compatibility
-------------
Automatic storage works for all nodes in the 'storage' group.

If the container doesn't use the "main" inventory list it additionally needs
to be added to the 'auto_storage.compat' table in the form:
[modname:nodename] = "invenotry list name"

API
---
Call 'auto_storage.store_to_nearby(player, range)' to trigger the storage function.
range - uses maximum metric and can be omitted


License
-------
MIT License

Copyright (c) 2023 Skamiz Kazzarch

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.








Warning: this method of storage bypasses inventory callbacks.
