.PHONY: everyday library bootstrap stage1 stage2 stage3 clean

# ----------------------------------------------------------------------------
# Choose a target.

ifndef TARGET
  TARGET := native
endif

# ----------------------------------------------------------------------------
# Define the files that form the library.

ifeq ($(TARGET),byte)
  LIBFILES := menhirLib.cmo
else
  LIBFILES := menhirLib.cmo menhirLib.cmx
endif

# ----------------------------------------------------------------------------
# Ocamlbuild tool and settings.

# Both targets "library" and "stage1" use "_stage1" as the build directory.
# This used to be fine with ocamlbuild, but starting with ocamlbuild 4.03,
# the flag -no-hygiene is required.

OCAMLBUILD := ocamlbuild -classic-display -no-hygiene -j 0 -cflags "-safe-string -bin-annot"

# ----------------------------------------------------------------------------
# For everyday development.
# Typing "make" will perform just stage 1. This is enough to ensure that
# the source code is correct.

everyday: installation.ml stage1

# ----------------------------------------------------------------------------
# Building MenhirLib.

library:
	$(OCAMLBUILD) $(LIBFILES)

# ----------------------------------------------------------------------------
# Building Menhir from scratch (a.k.a. bootstrapping).

bootstrap: .versioncheck stage1 stage2 stage3

# ----------------------------------------------------------------------------
# Checking the version of the OCaml compiler.

.versioncheck:
	@ echo Checking that OCaml is recent enough...
	@ ocaml checkOCamlVersion.ml --verbose --gt "4.02"
	@ touch $@

# ----------------------------------------------------------------------------
# Stage 1.
# Build Menhir using ocamlyacc.

stage1:
	@$(OCAMLBUILD) -build-dir _stage1 menhir.$(TARGET)

# ----------------------------------------------------------------------------
# Stage 2.
# Build Menhir using Menhir (from stage 1).

# Do not use . to refer to the current directory, because ocamlbuild
# descends into another directory when executing commands.
# Do not use $(shell pwd) either, because this assumes we are running
# on a Unix platform, and can fail on Windows.
# So, use .., which works fine if ocamlbuild has effectively descended
# into a subdirectory.
SRC   := ..

FLAGS := -v -lg 1 -la 1 -lc 1 --table --infer --stdlib $(SRC) --strict --fixed-exception --canonical

stage2:
	@$(OCAMLBUILD) -build-dir _stage2 -tag fancy_parser \
	  -use-menhir -menhir "$(SRC)/_stage1/menhir.$(TARGET) $(FLAGS)" \
	  menhir.$(TARGET)

# ----------------------------------------------------------------------------
# Stage 3 (optional).
# Re-generate Menhir's parser using Menhir (from stage 2) and check that it
# is identical to the stage 2 parser.
stage3:
	@$(OCAMLBUILD) -build-dir _stage3 -tag fancy_parser \
	  -use-menhir -menhir "$(SRC)/_stage2/menhir.$(TARGET) $(FLAGS)" \
	  parser.ml parser.mli
	@for i in parser.ml parser.mli ; do \
	  if ! diff _stage2/$$i _stage3/$$i 2>&1 >/dev/null ; then \
	    echo "Bootstrap FAILED: $$i did not reach a fixed point."; exit 1 ; \
	  fi ; \
	done; \
	echo "Bootstrap successful."

# ----------------------------------------------------------------------------
# Cleaning up.

clean::
	rm -rf .versioncheck _build _stage1 _stage2 _stage3
