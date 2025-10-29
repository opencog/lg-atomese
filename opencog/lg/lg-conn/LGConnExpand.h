/*
 * LGConnExpand.h
 *
 * Copyright (C) 2024 OpenCog Foundation
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

#ifndef _OPENCOG_LG_CONN_EXPAND_H
#define _OPENCOG_LG_CONN_EXPAND_H

#include <opencog/atoms/core/FunctionLink.h>
#include <opencog/lg/types/atom_types.h>

namespace opencog
{

/// The LgConnExpand link expands a Link Grammar connector into its
/// constituent parts: subtypes, main type, and direction.
///
/// The expected format can be either:
///
///     LgConnExpand
///         LgConnNode "hWV+"
///
/// or
///
///     LgConnExpand
///         LgConnector
///             LgConnNode "NXi"
///             LgConnDir "-"
///             LgConnMulti "@"
///
/// When executed, these return respectively:
///
///     Connector
///         LgSubType "h"
///         LgConnType "WV"
///         LgConnDir "+"
///
///     Connector
///         LgConnType "NX"
///         LgSubType "i"
///         LgConnDir "-"
///         LgConnMulti "@"
///
class LGConnExpand : public FunctionLink
{
protected:
	void init();

public:
	LGConnExpand(const HandleSeq&&, Type = LG_CONN_EXPAND);
	LGConnExpand(const LGConnExpand&) = delete;
	LGConnExpand& operator=(const LGConnExpand&) = delete;

	virtual ValuePtr execute(AtomSpace*, bool);

	static Handle factory(const Handle&);
};

LINK_PTR_DECL(LGConnExpand)
#define createLGConnExpand CREATE_DECL(LGConnExpand)

}

#endif // _OPENCOG_LG_CONN_EXPAND_H
