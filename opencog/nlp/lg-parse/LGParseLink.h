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
#include <opencog/nlp/types/atom_types.h>

namespace opencog
{
/** \addtogroup grp_atomspace
 *  @{
 */

/// Link Grammar parser.
///
/// An atomspace wrapper to the LG parser.
/// The LGParseLink places a full parse into the atomspace, including
/// the disjuncts and the link-instances.
///
/// The LGParseMinimal ony places the words, word-sequence and links
/// into the atomspace.

class LGParseLink : public FunctionLink
{
protected:
	void init();
	const char* get_word_string(Linkage, int, const char*) const;
	HandleSeq make_conseq(Linkage, int) const;
	void make_djs(Linkage, const char*, AtomSpace*) const;
	Handle cvt_linkage(Linkage, int, const char*, const char*,
	                   bool, AtomSpace*) const;

public:
	LGParseLink(const HandleSeq&&, Type=LG_PARSE_LINK);
	LGParseLink(const LGParseLink&) = delete;
	LGParseLink& operator=(const LGParseLink&) = delete;

	// Return a pointer to the atom being specified.
	virtual ValuePtr execute(AtomSpace*, bool);

	static Handle factory(const Handle&);
};

class LGParseMinimal : public LGParseLink
{
public:
	LGParseMinimal(const HandleSeq&&, Type=LG_PARSE_MINIMAL);
	LGParseMinimal(const LGParseMinimal&) = delete;
	LGParseMinimal& operator=(const LGParseMinimal&) = delete;
};

class LGParseDisjuncts : public LGParseLink
{
public:
	LGParseDisjuncts(const HandleSeq&&, Type=LG_PARSE_DISJUNCTS);
	LGParseDisjuncts(const LGParseDisjuncts&) = delete;
	LGParseDisjuncts& operator=(const LGParseDisjuncts&) = delete;
};

LINK_PTR_DECL(LGParseLink)
#define createLGParseLink CREATE_DECL(LGParseLink)

LINK_PTR_DECL(LGParseMinimal)
#define createLGParseMinimal CREATE_DECL(LGParseMinimal)

LINK_PTR_DECL(LGParseDisjuncts)
#define createLGParseDisjuncts CREATE_DECL(LGParseDisjuncts)

/** @}*/
}
#endif // _OPENCOG_LG_PARSE_H
