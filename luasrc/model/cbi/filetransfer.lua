local fs = require "luci.fs"
local http = luci.http

ful = SimpleForm("upload", translate("Upload"), nil)
ful.reset = false
ful.submit = false

sul = ful:section(SimpleSection, "", translate("Upload file to '/tmp/upload/'"))

fu = sul:option(FileUpload, "")
fu.template = "filetransfer/other_upload"

um = sul:option(DummyValue, "", nil)
um.template = "filetransfer/other_dvalue"

fdl = SimpleForm("download", translate("Download"), nil)
fdl.reset = false
fdl.submit = false

sdl = fdl:section(SimpleSection, "", translate("Download file"))

fd = sdl:option(FileUpload, "")
fd.template = "filetransfer/other_download"

dm = sdl:option(DummyValue, "", nil)
dm.template = "filetransfer/other_dvalue"

function Download()
	local sPath, sFile, fd, block
	sPath = http.formvalue("dlfile")
	sFile = nixio.fs.basename(sPath)
	if luci.fs.isdirectory(sPath) then
		fd = io.popen('tar -C "%s" -cz .' % {sPath}, "r")
		sFile = sFile .. ".tar.gz"
	else
		fd = nixio.open(sPath, "r")
	end
	if not fd then
		dm.value = translate("Couldn't open file: ") .. sPath
		return
	end
	dm.value = nil
	http.header('Content-Disposition', 'attachment; filename="%s"' % {sFile})
	http.prepare_content("application/octet-stream")
	while true do
		block = fd:read(nixio.const.buffersize)
		if (not block) or (#block ==0) then
			break
		else
			http.write(block)
		end
	end
	fd:close()
	http.close()
end
