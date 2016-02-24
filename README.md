# Password_Encode
File or Streaming strong Encryption from easy to remember passwords.

This is an easy to implement, easy to use encryption system for a user that uses a plain UTF-8
text string as the encryption key. -- right out of the box,
anyone should be able to reliably encrypt and decrypt any file, or if incorporated into a script
or network service, any stream. The encryption is simple enough to re-write in any language that
supports individual byte + math manipulation (it's helpful to have a handy native base64 implementation).
What makes this encryption practical and effective is the variable length of the keys and the potential
ease of remembering them so they don't have to be stored or catalogued.

The idea is to make the number
of passwords and their length just as important as the value of each character, and the user-frientliness
of inputing the passwords the same for any user young through old, asian or european. Using a UTF-8 string as
the password means the exact number of cells (characters) does not equal the exact number of bytes.
Because standard newlines, form-feeds, tabs, and line-returns (anything byte-valued below a space) are ignored
the platform, whether network, Operating System, or CPU Architecture, shouldn't matter and the user
may write entire poems or multiline phrases as a key.  All characters
or symbols standard to a user's language input should be accepted (only it must be in UTF-8 unless modified
to match some other Unicode input. The actual interpreted value for any character is actually limited to
a modulus of 64. This means the effect on the original file stream cannot be guessed by any language-locale
or propensity for fancy symbols. Also, the encoding shifts and swaps the placement of bytes so there is no
guess-ably clear pattern in the bit stream.  One simply must have the original passwords to decrypt the file.

The encryption is not intended to replace existing encryption technology for remote sessions or network use.
It is only for file storage, safe transport, and retrieval. Also, with the open-source, heart-driven effort
this project represents, there is no implied warranty or guarantee that some vulnerability can't, hasn't,
or won't be discovered.  No warrantee could possibly be given at my limited security and encryption
level of experience. Even so, this was designed specifically so that banks or people with secrets could deliver
or store their information in a way that only the holder of passwords could retrieve.  A single character
different, added, or missing would not necessarily show much difference for the first dozen bytes, but would
throw a decryption attempt off for most of the rest of the file, returning random garbage. For convinience
and universal portability, each processed chunk of data is 57 bytes long, matching the 76 base64 representation.
This system allows easy integration with efficient file encryption into an email or compression format.

Whether you are a regular person who has sensitive information or a super up-tight security master,
the simple but effective nature having variable length/number-of passwords (1 to theoretically infinity
characters in length) makes your encryption key(s) easy enough to remember that you don't have
to write it down or save it where it can be seen,
and secure enough that even a security expert could work for months or years
trying to decrypt a single file (requires longer passwords). 

Currently, One old and incomplete version is compiled from C# for .Net, so it can run on any machine that has .NET
installed (Mono for Linux/Mac) My souces are in a scattered mess after a necessary upgrade/conversion
to hosting computer system, so all I have easily available is the compiled executable. I do not
plan on organizing and uploading the rest of the .NET souces until after I complete rewriting the
program in Ada. My plan is to make a common, reliable source that can be compiled to .NET,
Java Virtual Machine, and to native machine code for Android/iOS/Linux/Mac/Windows. This major ambition is
inherent with my goal of being an effective programmer and catoring to the intended users.  The major
deficiency of the .NET program is that it does not present a GUI, nor any useful prompts, nor have
a made any kind of file interaction, just standard-in and standard-out.  If you look at it as consistent and reliable
across all platforms this may actually be considered a benefit instead of a deficiency, because
in its simplicity it can only be used one way and that way can be plugged into any systems locally
supported scripting software.  Ideally, I want the product to be easy to compile and implement on any machine
and with reliable performance and results.  For reliability, portability, and elegance I have chosen Ada as
the primary language for the source code.  It's integration with C/C++/Java/Fortran/COBOL and maybe
even C# one day makes it possibly to use almost anywhere with other software.

I fave fancied that a future version will use GTK or another local or native GUI toolkit when the
"-gui", or "-macgui", "-wingui", or "-ratpoison"/lib-name 
option is given, and to have the option of specifying that very long keys be stored locally, encrypted by short
passwords that are easier to type/remember.  With the current obscurity of this project and the
relative difficulty of reading files in anyone's local operating system account, this should make simple,
familiar, password based encryption possible as well as the integrated or explicit encrytion. I
have also fancied making the commandline/library inteface compatible with GPG/PGP, but I don't think
this encryption is strong enough to replace it -- it would just be more easy to interface with it.

The .NET compiled program has support for only one or two passwords and only the default algorithms on those.
The newest version should be mostly compatible, but I have not yet gotten to the testing stage,
and I am willing to sacrefice my foolish choice of simple algorithms for a slightly more CPU intensive default
if it makes it more secure.  Several very simple algorithms will be builtin that will maintain the idea
of portability, while being very nearly impossible to crack.  The old default will still be supported
in some way, so that anyone using a new version with an old will not perminantly lose something very important.
(Algorithms can be chosen by command line options or by connected software).














