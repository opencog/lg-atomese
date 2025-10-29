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
#include <opencog/lg/types/atom_types.h>
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
	if (LG_CONN_NODE != t && LG_CONNECTOR != t)
		throw InvalidParamException(TRACE_INFO,
			"LgConnExpand: Expecting LgConnNode or LgConnector, got %s",
			oset[0]->to_string().c_str());
}

ValuePtr LGConnExpand::execute(AtomSpace* as, bool silent)
{
	std::string conn_str;
	Handle dir_handle;
	Handle multi_handle;

	// Extract components based on input type
	Type input_type = _outgoing[0]->get_type();

	if (LG_CONN_NODE == input_type)
	{
		// Simple case: just a connector string
		conn_str = _outgoing[0]->get_name();
	}
	else if (LG_CONNECTOR == input_type)
	{
		// Complex case: LgConnector with children
		const HandleSeq& connector_parts = _outgoing[0]->getOutgoingSet();

		for (const Handle& part : connector_parts)
		{
			Type pt = part->get_type();
			if (LG_CONN_NODE == pt)
				conn_str = part->get_name();
			else if (LG_CONN_DIR_NODE == pt)
				dir_handle = part;
			else if (LG_CONN_MULTI_NODE == pt)
				multi_handle = part;
		}
	}

	if (conn_str.empty())
		throw InvalidParamException(TRACE_INFO,
			"LgConnExpand: Empty connector string");

	// Parse the connector string
	size_t i = 0;
	size_t len = conn_str.length();
	HandleSeq outgoing;

	// Leading @ (multi-connector) - only if not already provided in LgConnector
	if (i < len && conn_str[i] == '@')
	{
		if (!multi_handle)
			multi_handle = createNode(LG_CONN_MULTI_NODE, "@");
		i++;
	}

	// Leading lowercase letters (subtypes before main type)
	while (i < len && islower(conn_str[i]))
	{
		std::string subtype(1, conn_str[i]);
		outgoing.push_back(createNode(LG_SUB_TYPE, std::move(subtype)));
		i++;
	}

	// Sequence of uppercase letters (main type)
	size_t start = i;
	while (i < len && isupper(conn_str[i]))
		i++;

	if (i > start)
	{
		std::string main_type = conn_str.substr(start, i - start);
		outgoing.push_back(createNode(LG_CONN_TYPE, std::move(main_type)));
	}

	// Trailing lowercase letters and wildcards (subtypes after main type)
	while (i < len && (islower(conn_str[i]) || conn_str[i] == '*'))
	{
		std::string subtype(1, conn_str[i]);
		outgoing.push_back(createNode(LG_SUB_TYPE, std::move(subtype)));
		i++;
	}

	// Trailing +/- (direction) - only if not already provided in LgConnector
	if (i < len && (conn_str[i] == '+' || conn_str[i] == '-'))
	{
		if (!dir_handle)
		{
			std::string direction(1, conn_str[i]);
			dir_handle = createNode(LG_CONN_DIR_NODE, std::move(direction));
		}
		i++;
	}

	// Add direction if present
	if (dir_handle)
		outgoing.push_back(dir_handle);

	// Add multi-connector if present
	if (multi_handle)
		outgoing.push_back(multi_handle);

	// Return as a Connector link
	return createLink(outgoing, CONNECTOR);
}

DEFINE_LINK_FACTORY(LGConnExpand, LG_CONN_EXPAND)
