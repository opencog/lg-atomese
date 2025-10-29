/*
 * LGParseLink.h
 *
 * Copyright (C) 2017 Linas Vepstas
 *
 * Author: Linas Vepstas <linasvepstas@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License v3 as
 * published by the Free Software Foundation and including the exceptions
 * at http://opencog.org/wiki/Licenses
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program; if not, write to:
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef _OPENCOG_LG_PARSE_H
#define _OPENCOG_LG_PARSE_H

#include <link-grammar/link-includes.h>

#include <opencog/atoms/core/FunctionLink.h>
#include <opencog/lg/types/atom_types.h>

namespace opencog
{
/** \addtogroup grp_atomspace
 *  @{
 */

/// Link Grammar parser.
///
/// An AtomSpace wrapper to the LG parser.
/// LgParseBonds
/// LgParseSections
/// LgParseDisjuncts -- Return the disjuncts used in the parse.

class LGParseLink : public FunctionLink
{
protected:
	void init();
	std::string get_word_string(Linkage, int, const char*) const;
	HandleSeq make_lg_conseq(Linkage, int, AtomSpace*) const;
	HandleSeq make_conseq(Linkage, int, const char*, AtomSpace*) const;
	ValuePtr make_djs(Linkage, const char*, AtomSpace*) const;
	ValuePtr make_sects(Linkage, const char*, AtomSpace*) const;
	ValuePtr make_bonds(Linkage, const char*, AtomSpace*) const;
	ValuePtr make_words(Linkage, const char*, AtomSpace*) const;

public:
	LGParseLink(const HandleSeq&&, Type=LG_PARSE_LINK);
	LGParseLink(const LGParseLink&) = delete;
	LGParseLink& operator=(const LGParseLink&) = delete;

	// Return a pointer to the atom being specified.
	virtual ValuePtr execute(AtomSpace*, bool);

	static Handle factory(const Handle&);
};

class LGParseDisjuncts : public LGParseLink
{
public:
	LGParseDisjuncts(const HandleSeq&&, Type=LG_PARSE_DISJUNCTS);
	LGParseDisjuncts(const LGParseDisjuncts&) = delete;
	LGParseDisjuncts& operator=(const LGParseDisjuncts&) = delete;
};

class LGParseSections : public LGParseLink
{
public:
	LGParseSections(const HandleSeq&&, Type=LG_PARSE_SECTIONS);
	LGParseSections(const LGParseSections&) = delete;
	LGParseSections& operator=(const LGParseSections&) = delete;
};

class LGParseBonds : public LGParseLink
{
public:
	LGParseBonds(const HandleSeq&&, Type=LG_PARSE_BONDS);
	LGParseBonds(const LGParseBonds&) = delete;
	LGParseBonds& operator=(const LGParseBonds&) = delete;
};

LINK_PTR_DECL(LGParseLink)
#define createLGParseLink CREATE_DECL(LGParseLink)

LINK_PTR_DECL(LGParseDisjuncts)
#define createLGParseDisjuncts CREATE_DECL(LGParseDisjuncts)

LINK_PTR_DECL(LGParseSections)
#define createLGParseSections CREATE_DECL(LGParseSections)

LINK_PTR_DECL(LGParseBonds)
#define createLGParseBonds CREATE_DECL(LGParseBonds)

/** @}*/
}
#endif // _OPENCOG_LG_PARSE_H
