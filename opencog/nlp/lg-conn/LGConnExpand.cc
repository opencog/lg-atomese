/*
 * LGConnExpand.cc
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

#include <opencog/atoms/atom_types/NameServer.h>
#include <opencog/atoms/base/Node.h>
#include <opencog/atomspace/AtomSpace.h>
#include <opencog/nlp/types/atom_types.h>
#include "LGConnExpand.h"

using namespace opencog;

/// The expected format of LgConnExpand is:
///
///     LgConnExpand
///         LgConnNode "Ds**c"
///
/// When executed, the connector string is parsed into:
/// - Leading capital letters -> LgConnType
/// - Each subsequent character -> LgSubType
///
/// Returns:
///     Connector
///         LgConnType "D"
///         LgSubType "s"
///         LgSubType "*"
///         LgSubType "*"
///         LgSubType "c"
///
LGConnExpand::LGConnExpand(const HandleSeq&& oset, Type t)
	: FunctionLink(std::move(oset), t)
{
	if (not nameserver().isA(t, LG_CONN_EXPAND))
	{
		const std::string& tname = nameserver().getTypeName(t);
		throw InvalidParamException(TRACE_INFO,
			"Expecting an LgConnExpand, got %s", tname.c_str());
	}
	init();
}

void LGConnExpand::init()
{
	const HandleSeq& oset = _outgoing;

	size_t osz = oset.size();
	if (1 != osz)
		throw InvalidParamException(TRACE_INFO,
			"LgConnExpand: Expecting one argument, got %lu", osz);

	Type t = oset[0]->get_type();
	if (LG_CONN_NODE != t)
		throw InvalidParamException(TRACE_INFO,
			"LgConnExpand: Expecting LgConnNode, got %s",
			oset[0]->to_string().c_str());
}

ValuePtr LGConnExpand::execute(AtomSpace* as, bool silent)
{
	// Get the connector string
	const std::string& conn_str = _outgoing[0]->get_name();

	if (conn_str.empty())
		throw InvalidParamException(TRACE_INFO,
			"LgConnExpand: Empty connector string");

	// Parse the connector string
	// Leading capital letters form the main type
	size_t i = 0;
	while (i < conn_str.length() && isupper(conn_str[i]))
		i++;

	if (i == 0)
		throw InvalidParamException(TRACE_INFO,
			"LgConnExpand: Connector string must start with capital letter: %s",
			conn_str.c_str());

	std::string main_type = conn_str.substr(0, i);

	// Build the output handle sequence
	HandleSeq outgoing;

	// Add the main connector type
	outgoing.push_back(createNode(LG_CONN_TYPE, std::move(main_type)));

	// Add each subsequent character as a subtype
	while (i < conn_str.length())
	{
		std::string subtype(1, conn_str[i]);
		outgoing.push_back(createNode(LG_SUB_TYPE, std::move(subtype)));
		i++;
	}

	// Return as a Connector link
	return createLink(outgoing, CONNECTOR);
}

DEFINE_LINK_FACTORY(LGConnExpand, LG_CONN_EXPAND)
