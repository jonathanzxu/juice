from subprocess import *
import os
import sys
def thejuice():
    print("updating repos...")
    run("cp ./sources.list /etc/apt/sources.list", shell=True)
    run("cp ./10periodic /etc/apt/apt.conf.d/10periodic", shell=True)
    print("done.")
    print("removing aliases...")
    run("unalias -a", shell=True)
    print("done.")
    print("installing needed packages...")
    run("apt install -y libpam-cracklib ufw clamav", shell=True, stdout=PIPE)
    print("done.")
    print("setting password & lockout policy...")
    run("cp ./common-auth /etc/pam.d/common-auth", shell=True)
    run("cp ./common-password /etc/pam.d/common-password", shell=True)
    run("cp ./cracklib.conf /etc/cracklib/cracklib.conf", shell=True)
    run("cp ./login.defs /etc/login.defs", shell=True)
    print("done.")
    print("configuring sysctl and applying changes...")
    run("cp ./sysctl.conf /etc/sysctl.conf", shell=True)
    run(["sysctl", "-ep"])
    print("done.")
    print("disabling guest account...")
    run('cp ./lightdm.conf /etc/lightdm/lightdm.conf', shell=True)
    run('cp ./lightdm.conf /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf', shell=True)
    print("done.")
    print("Configuring firewall...")
    run("ufw --force reset", shell=True)
    run("ufw deny 23", shell=True)
    run("ufw deny 2049", shell=True)
    run("ufw deny 515", shell=True)
    run("ufw deny 111", shell=True)
    run("ufw enable", shell=True)
    print("done.")
    print("deleting unaauthorized media files...")
    run("find / -name *.mp3 -type f -delete", shell=True)
    run("find / -name *.mov -type f -delete", shell=True)
    run("find / -name *.mp4 -type f -delete", shell=True)
    run("find / -name *.avi -type f -delete", shell=True)
    run("find / -name *.mpg -type f -delete", shell=True)
    run("find / -name *.mpeg -type f -delete", shell=True)
    run("find / -name *.flac -type f -delete", shell=True)
    run("find / -name *.m4a -type f -delete", shell=True)
    run("find / -name *.flv -type f -delete", shell=True)
    run("find / -name *.ogg -type f -delete", shell=True)
    run("find /home -name *.gif -type f -delete", shell=True)
    run("find /home -name *.png -type f -delete", shell=True)
    run("find /home -name *.jpg -type f -delete", shell=True)
    run("find /home -name *.jpeg -type f -delete", shell=True)
    print("done.")
    print("scanning for plaintext password files...")
    adminpassword = input("Type any admin password to search for: ")
    ptpasswdfile = run(["grep", "-r", adminpassword, "/boot", "/etc", "/home", "/bin"], stdout=PIPE)
    pwfiles = ptpasswdfile.stdout.decode().count('\n')
    if pwfiles > 0:
        print("\033[91m {}\033[00m".format("WARNING: %d PLAINTEXT PASSWORD FILES FOUND!!!" % pwfiles))
        print(ptpasswdfile.stdout.decode())
    else:
        print("no plaintext password files found in /boot, /etc, /home, or /bin.")
    print("auditing authorized users and admins...")
    fetchusers = run("awk -F: '($3>=1000)&&($1!=\"nobody\"){print $1}' /etc/passwd", stdout=PIPE, shell=True)
    currentusers = fetchusers.stdout.decode().splitlines()
    with open("users.txt", "r") as users:
        authusers = users.read().splitlines()
        for curruser in currentusers:
            if curruser not in authusers:
                run(["deluser", curruser])
        for user in authusers:
            if user not in currusers:
                run(["adduser", user, "--gecos", "\",,,\"", "--disabled-password"], stdout=PIPE)
                pwdedit = user + ":s3cur3P@55"
                editor = Popen(["chpasswd", stdin=PIPE)
                editor.communicate(input=pwdedit.encode())
    print("unauthorized users deleted and authorized users added.")
    fetchadmins = run("awk -F: '/sudo/{print $4}' /etc/group", stdout=PIPE, shell=True)
    currentadmins = fetchadmins.stdout.decode().split(',')
    with open("admins.txt", "r") as admins:
        authadmins = admins.read().splitlines()
        for curradmin in currentadmins:
            if curradmin.rstrip() not in authadmins:
                run(["deluser", curradmin.rstrip(), "sudo"], stdout=PIPE)
                run(["deluser", curradmin.rstrip(), "adm"], stdout=PIPE)
        for admin in authadmins:
            if admin not in currentadmins:
                run(["adduser", admin, "sudo"], stdout=PIPE)
                run(["adduser", admin, "adm"], stdout=PIPE)
    print("unauthorized admins demoted and authorized admins promoted.")
    fetchroots = run("awk -F: '($3==0){print $1}' /etc/passwd", stdout = PIPE, shell=True)
    currroots = fetchroots.stdout.decode().splitlines()
    for root in currroots:
        if root != "root":
            run(["deluser", root], stdout=PIPE)
    print("unauthorized root accounts deleted.")
    print("settings secure passwords and chage...")
    for user in authusers:
        passchanger = Popen(["passwd", user], stdin=PIPE, stdout=PIPE)
        passchanger.communicate(input="s3cur3P@55\ns3cur3P@55".encode())
        run(["chage", "-m", "6", user])
        run(["chage", "-M", "15", user])
        run(["chage", "-W", "7", user])
        run(["chage", "-I", "5", user])
    print("all user passwords changed to: s3cur3P@55")
    print("setting important file permissions...")
    run(["chmod", "600", "/boot/grub/grub.cfg"])
    run(["chmod", "644", "/etc/passwd"])
    run(["chmod", "640", "/etc/shadow"])
    run(["chmod", "644", "/etc/group"])
    run(["chmod", "640", "/etc/gshadow"])
    run(["chmod", "000", "/usr/bin/as"], stdout=PIPE, stderr=PIPE)
    run(["chmod", "000", "/usr/bin/byacc"], stdout=PIPE, stderr=PIPE)
    run(["chmod", "000", "/usr/bin/yacc"], stdout=PIPE, stderr=PIPE)
    run(["chmod", "000", "/usr/bin/bcc"], stdout=PIPE, stderr=PIPE)
    run(["chmod", "000", "/usr/bin/kgcc"], stdout=PIPE, stderr=PIPE)
    run(["chmod", "000", "/usr/bin/cc"], stdout=PIPE, stderr=PIPE)
    run(["chmod", "000", "/usr/bin/gcc"], stdout=PIPE, stderr=PIPE)
    run(["chmod", "000", "/usr/bin/*c++"], stdout=PIPE, stderr=PIPE)
    run(["chmod", "000", "/usr/bin/*g++"], stdout=PIPE, stderr=PIPE)
    run("echo tty1 > /etc/securetty", shell=True)
    run(["chmod", "0600", "/etc/securetty"])
    run(["chmod", "700", "/root"])
    print("file permissions set.")
    #FSTAB DISABLED FOR NOW, KINDA BROKE
    #print("securing fstab.")
    #run("echo none /run/shm tmpfs defaults,ro,nodev,noexec,nosuid 0 0 > /etc/fstab", shell=True)
    #run("echo none /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0 > /etc/fstab", shell=True)
    #run("echo none /var/tmp tmpfs defaults,noexec,nodev,nosuid 0 0 > /etc/fstab", shell=True)
    #print("done.")
    print("disabling root login...")
    run(["passwd", "-l", "root"])
    print("done.")
    print("Removing harmful software (KNOWN)...")
    badpackages = ["john", "netcat*", "bind9", "telnet*", "iodine", "kismet", "medusa", "hydra", "rsh-server", "ophcrack", "fcrackzip", "ayttm", "empathy", "nikto", "logkeys", "nfs-kernel-server", "vino", "tightvncserver", "rdesktop", "remmina", "vinagre", "ettercap", "knocker", "openarena-server", "wireshark", "minetest", "minetest-server", "nmap", "freeciv-server", "freeciv-client-gtk", "freeciv", "p0f", "snmpd", "at"]
    for package in badpackages:
        run(["apt", "-y", "purge", package], stdout=PIPE)
    run("apt -y install --reinstall ubuntu-desktop", shell=True, stdout=PIPE)
    run("apt -y autoremove", shell=True, stdout=PIPE)
    print("done.")




if os.geteuid() == 0:
    if not (input('Did you complete forensics questions, read README, make authorized user (including admins) file named users.txt and authorized admin file named admins.txt? [yes/no]') == "yes"):
        print("do it then")
        exit()
    thejuice()
else:
    print("Y'aint root...try again")
    exit()

