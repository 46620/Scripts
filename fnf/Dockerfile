FROM ubuntu:21.10

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y git g++-multilib gcc-multilib haxe && rm -rf /var/lib/apt/lists/*

RUN haxelib setup /usr/local/share/haxe/lib && haxelib install lime 7.9.0 && haxelib install openfl && haxelib install flixel && haxelib install flixel-tools && haxelib install flixel-ui && haxelib install hscript && haxelib install flixel-addons && haxelib install actuate && cp "/usr/local/share/haxe/lib/lime/7,9,0/templates/bin/lime.sh" /usr/local/bin/lime && chmod 755 /usr/local/bin/lime && haxelib run lime setup flixel && echo "haxelib run flixel-tools \"$@\"" > /usr/local/bin/flixel && chmod 755 /usr/local/bin/flixel && haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit.git && haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit && haxelib git faxe https://github.com/uhrobots/faxe && haxelib git polymod https://github.com/MasterEric/polymod.git && haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc && haxelib git extension-webm https://github.com/KadeDev/extension-webm && lime rebuild extension-webm linux

WORKDIR /fnf

CMD ["lime", "build", "linux"]