function pkgu --description 'uninstall .pkg packages' --argument package
    echo "Uninstalling $package"
    pkgutil --files $package | while read _file
        if ! pkgutil --file-info $_file | grep "^pkgid: " | grep -v $package >/dev/null
            rm -rf $file || echo >&2 "E: can not remove $file"
        end
    end
    pkgutil --forget $package
end
