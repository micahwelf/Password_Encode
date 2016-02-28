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
throw a decryption attempt off for most of the rest of the file, returning random garbage. For convenience
and universal portability, each processed chunk of data is 57 bytes long, matching the typical 76 base64 representation.
This system allows easy integration with efficient file encryption into an email or compression format.
This is not ideal, cryptographically speaking, however, if a person changes that default buffer/unit
length to  a larger size the exact same size must also be used when decrypting.  Also, 57 bytes is great
for streaming through a pipe or into email, but very poor encryption length if you know the type of file
and the algorithm, since a cracker would just try the whatever makes a recognizable header for that file type;
therefore, for serious encryption (bank/government) either very long keys (maybe three 2048 character keys) should
be used, or the encoding buffer should be increased to an appropriate size that is a multiple of three
(1026+, there is no defined limit, but
system memory could impose a limit in the range of a few hundred million).

Whether you are a regular person who has sensitive information or a super up-tight security master,
the simple but effective nature having variable length/number-of passwords (1 to theoretically infinity
characters in length) makes your encryption key(s) easy enough to remember that you don't have
to write it down or save it where it can be seen,
and secure enough that even a security expert could work for months or years
trying to decrypt a single file (requires longer than typical login passwords). 

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

If you want to improve this program, please maintain a fork connected to it and communicate with
me.  It would be really cool for us to improve our group project skills and experience.
If you want to download the project and improve it or treat it as GPL, then please let me know.
I prefer the LGPL 3.0 or MIT, because I want to maintain a universal benefit from this project.

##In relation to licensing and the value provided by open source projects to the world, I have some
comments that I hope you will consider and publicly support, as follows:

Open Source is the best, but not everything should be so limited, since some things need to be funded
for continuous support or are appropriately crafted as a sell-able product.  I am, how-ever, strongly
opposed to the concept of software patents.  In my coding I would prefer just pretend they don't
exist, since they shouldn't -- and actually, they obstruct the very purpose (regular-) patents were
legalized for.  Earlier law makers could not have forseen how huge a counter-intuitive impact patents
have had on good software development.  The only conceivable benefit I have observed is the general
discouragement from the average person pirating DVDs or software that has been the subject of some
investment.  Microsoft and IBM didn't need patents to protect their work, since copyright law
would have sufficed, and if copyright law wasn't quite adequate, a number of enhancements to cover
cross-language transcriptions, penalties, and the like would have been enough.  By the very mathematically
constant nature of any computer algorithm, it will eventually be discovered and used, repeatedly.  Inventions
of a more physical nature are inherently different in that there are many, many, many more possibilities
than anyone may ever observe in a life-time.  How these two then compare in the context of furthering
the development
of science and wealth in the United States and the world, is that stopping the inevitable discovery
and use of a computer algorithm slows the growth and development of the entire field of science and industry,
while stopping duplicate production and sale of an idea patented as a non-algoritmic, physical invention
focuses the profits to an individual or group, increasing industry and providing much needed incentive
to put effort into the science and industry with the hope of reward.  Since software patents have
historically only slowed progress, and sometimes been ignored due to the ridiculously redundant effort
of enforcing some of them, I am surprised that we as a nation still legally support them.  To summarize
my point, if Intel holds a patent for a particular design of chip, they exclusively support, develop,
and profit financially from the chip and every one else benefits more from it; Whereas, if Intel also
patents a software formula that would make software run 1/3 faster, utilizing the new chip, and then
enforces that patent, everyone's progress slows, including even the incentive for Intel to keep inventing their
way to the future.  The software and designs they create may be their's, but the fundemental algorithm just like any
principle founded idea, belongs to no one and is only bound to someone by patent laws with the intent
that the whole of society will benefit.
If I am ever (some long future day)
approached about some software patent issue, I will very likely just archive my work and prepare an
alternative for the public project, like others have done.  Sometimes this process actually forces
a programmer to innovate something better, plus I am a person of principle and do not intend any
disrespect for someone else who has obtained a software patent.

The .NET version was not made on the AdaCore GPL runtime, and though it will be open source, it
is not yet and is not legally bound to be.  When it is ready, the Ada version may be compiled onto
.NET with the AdaCore GPL runtime, since it will be fine to make that item fully GPL, with the original
code possibly being LGPL like all encryption framework and components should be.
I want the code to enter general use when it is good enough to perform reliably for real use.
I am not yet decided on whether I will Use an MIT, BSD, or LGPL license.  They are very
similar and essencially cover what I have intended.  If you have any recommendations, send you comments
to my GitHub user-name at gmail.com.  This is my email as a programmer and is almost dedicated to that purpose.














