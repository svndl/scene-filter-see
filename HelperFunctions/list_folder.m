function listing = list_folder(folder)
%
% list folder content ignoring .,..,.DS, etc.

listing = dir(folder);
listing = listing(arrayfun(@(x) x.name(1), listing) ~= '.');