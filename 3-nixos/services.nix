{
	test1 =
	{ config, pkgs, ... }:
	{ services.httpd.adminAddr = "shd@nawia.net";
		services.httpd.documentRoot = "${pkgs.valgrind.doc}/share/doc/valgrind/html";
	};
}
