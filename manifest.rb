module NODE_HAVEN
  module Manifest
    # manifest list of files to download. [installer, ova]
    WINDOWSX64_MANIFEST = '{"install":["VirtualBox-6.0.8-r130520-MultiArch_amd64.msi"],
                            "cab": ["common.cab"],
                            "ext":["Oracle_VM_VirtualBox_Extension_Pack-6.0.8.vbox-extpack"],
                            "ova": ["NodeHavenUbuntu.zip"],
                            "certs":["oracle-1.cer","oracle-2.cer"]}'
    
    WINDOWSX86_MANIFEST = '{"install":["VirtualBox-6.0.8-r130520-MultiArch_x86.msi"],
                            "cab": ["common.cab"],
                            "ova": ["NodeHavenUbuntu.zip"],
                            "certs":["oracle-1.cer","oracle-2.cer"]}'
    
    LINUX_MANIFEST = '{"install":"virtualbox-6.0_6.0.8-130520_Ubuntu_bionic_amd64.deb", "ova":"NodeHavenUbuntu.zip"}'   
  end
end