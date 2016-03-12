{ nrMachines ? 2 }:

with import <nixpkgs/lib>;

let
	adminAddr = "shd@nawia.net";
	makeMachine = n: nameValuePair "backend${toString n}"
	({ config, pkgs, nodes, ... }:
	{ deployment.targetEnv = "virtualbox";
		deployment.virtualbox.headless = true;
		networking.firewall.allowedTCPPorts = [ 80 ];
		services.httpd.enable = true;
		services.httpd.adminAddr = adminAddr;
		services.httpd.documentRoot = "${pkgs.valgrind.doc}/share/doc/valgrind/html";
	}
	);
in
	listToAttrs (map makeMachine (range 1 nrMachines))
	//
	{
		test1 =
		{ config, pkgs, ... }:
		{ deployment.targetEnv = "virtualbox";
			deployment.virtualbox.headless = true;
			networking.firewall.allowedTCPPorts = [ 80 ];
			services.httpd.enable = true;
			services.httpd.adminAddr = adminAddr;
			services.httpd.extraModules = ["proxy_balancer" "lbmethod_byrequests"];
			services.httpd.extraConfig =
				''
					<Proxy balancer://cluster>
						Allow from all
				'' + (concatStringsSep "\n" (map (n: "BalancerMember http://backend${toString n} retry=0\n") (range 1 nrMachines))) + ''
					</Proxy>
					ProxyPass         /    balancer://cluster/
					ProxyPassReverse  /    balancer://cluster/
				'';
		};
	}
