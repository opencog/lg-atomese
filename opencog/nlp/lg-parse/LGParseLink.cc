/*
 * LGParseLink.cc
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

#include <atomic>
#include <uuid/uuid.h>
#include <link-grammar/link-includes.h>
#if LINK_MAJOR_VERSION == 5 && LINK_MINOR_VERSION >= 11
#include <link-grammar/dict-atomese.h>
#endif

#include <opencog/atoms/atom_types/NameServer.h>
#include <opencog/atoms/base/Node.h>
#include <opencog/atoms/core/NumberNode.h>
#include <opencog/atoms/value/LinkValue.h>
#include <opencog/atoms/value/StringValue.h>
#include <opencog/atomspace/AtomSpace.h>
#include <opencog/persist/api/StorageNode.h>
#include <opencog/nlp/lg-dict/LGDictNode.h>
#include "LGParseLink.h"

using namespace opencog;
void error_handler(lg_errinfo *ei, void *data);

/// The expected format of an LgParseLink is:
///
///     LgParseLink
///         PhraseNode "this is a test."
///         LgDictNode "en"
///         NumberNode  6   -- optional, number of parses.
///         AtomSpace  foo  -- optional, AtomSpace holding dict info.
///         StorageNode bar -- optional, StorageNode holding dict info.
///
/// When executed, the result of parsing the phrase text, using the
/// specified dictionary, is placed in the atomspace.  Execution
/// returns a Sentencenode pointing at the parse results.  If the third,
/// optional NumberNode is present, then that will be the number of
/// parses that are captured. If the NumberNode is not present, it
/// defaults to four.
///
/// If the `LgDictNode` specified an AtomSpace-backed dictionary, and
/// the fourth argument is present, then the dictionary word lookups
/// will be performed from the specified AtomSpace.  Note that
/// EvaluationLinks will be created in that AtomSpace, tying together
/// the LG connector types to the AtomSpace connector types. This is
/// the only reason for specifying an AtomSpace: to get back that info.
///
/// If the `LgDictNode` specified an AtomSpace-backed dictionary, and
/// the fifth argument is present, then the dictionary word lookups
/// will be performed from the specified StorageNode. Otherwise, if
/// an AtomSpace is specified, but the StorageNode is not, the parser
/// will use the AtomSpace contents only; the entire dictionary must
/// be present in the AtomSpace.
///
/// The LgParseLink is a kind of FunctionLink, and can thus be used in
/// any expression that FunctionLinks can be used with.
///
void LGParseLink::init()
{
	const HandleSeq& oset = _outgoing;

	size_t osz = oset.size();
	if (2 > osz or 5 < osz)
		throw InvalidParamException(TRACE_INFO,
			"LGParseLink: Expecting two to five arguments, got %lu", osz);

	Type pht = oset[0]->get_type();
	if (PHRASE_NODE != pht and (not oset[0]->is_executable()) and
	    VARIABLE_NODE != pht and GLOB_NODE != pht)
		throw InvalidParamException(TRACE_INFO,
			"LGParseLink: Expecting PhraseNode, got %s",
			oset[0]->to_string().c_str());

	Type dit = oset[1]->get_type();
	if (LG_DICT_NODE != dit and VARIABLE_NODE != dit and GLOB_NODE != dit)
		throw InvalidParamException(TRACE_INFO,
			"LGParseLink: Expecting LgDictNode, got %s",
			oset[1]->to_string().c_str());

	if (3 <= osz)
	{
		Type nit = oset[2]->get_type();
		if (NUMBER_NODE != nit and VARIABLE_NODE != nit and GLOB_NODE != nit)
			throw InvalidParamException(TRACE_INFO,
				"LGParseLink: Expecting NumberNode, got %s",
				oset[2]->to_string().c_str());
	}

	if (4 <= osz)
	{
		Type ast = oset[3]->get_type();
		if (ATOM_SPACE != ast and VARIABLE_NODE != ast and GLOB_NODE != ast)
			throw InvalidParamException(TRACE_INFO,
				"LGParseLink: Expecting AtomSpace, got %s",
				oset[3]->to_string().c_str());
	}

	if (5 <= osz)
	{
		Type stot = oset[4]->get_type();
	   if (not nameserver().isA(stot, STORAGE_NODE)
		    and VARIABLE_NODE != stot and GLOB_NODE != stot)
		throw InvalidParamException(TRACE_INFO,
				"LGParseLink: Expecting StorageNode, got %s",
				oset[4]->to_string().c_str());
	}
}

LGParseLink::LGParseLink(const HandleSeq&& oset, Type t)
	: FunctionLink(std::move(oset), t)
{
	// Type must be as expected
	if (not nameserver().isA(t, LG_PARSE_LINK))
	{
		const std::string& tname = nameserver().getTypeName(t);
		throw InvalidParamException(TRACE_INFO,
			"Expecting an LgParseLink, got %s", tname.c_str());
	}
	init();
}

LGParseMinimal::LGParseMinimal(const HandleSeq&& oset, Type t)
	: LGParseLink(std::move(oset), t)
{
	// Type must be as expected
	if (not nameserver().isA(t, LG_PARSE_MINIMAL))
	{
		const std::string& tname = nameserver().getTypeName(t);
		throw InvalidParamException(TRACE_INFO,
			"Expecting an LgParseMinimal, got %s", tname.c_str());
	}
	init();
}

LGParseDisjuncts::LGParseDisjuncts(const HandleSeq&& oset, Type t)
	: LGParseLink(std::move(oset), t)
{
	// Type must be as expected
	if (not nameserver().isA(t, LG_PARSE_DISJUNCTS))
	{
		const std::string& tname = nameserver().getTypeName(t);
		throw InvalidParamException(TRACE_INFO,
			"Expecting an LgParseDisjuncts, got %s", tname.c_str());
	}
	init();
}

LGParseSections::LGParseSections(const HandleSeq&& oset, Type t)
	: LGParseLink(std::move(oset), t)
{
	// Type must be as expected
	if (not nameserver().isA(t, LG_PARSE_SECTIONS))
	{
		const std::string& tname = nameserver().getTypeName(t);
		throw InvalidParamException(TRACE_INFO,
			"Expecting an LgParseSections, got %s", tname.c_str());
	}
	init();
}

LGParseBonds::LGParseBonds(const HandleSeq&& oset, Type t)
	: LGParseLink(std::move(oset), t)
{
	// Type must be as expected
	if (not nameserver().isA(t, LG_PARSE_BONDS))
	{
		const std::string& tname = nameserver().getTypeName(t);
		throw InvalidParamException(TRACE_INFO,
			"Expecting an LgParseBonds, got %s", tname.c_str());
	}
	init();
}

// =================================================================

ValuePtr LGParseLink::execute(AtomSpace* as, bool silent)
{
	// Executable links are a subset of those that can be declared.
	// Declarations can include VariableNodes & etc. but for execution,
	// evrything must be concrete. So check the args here; and not
	// in the ctor.
	if (LG_DICT_NODE != _outgoing[1]->get_type())
		throw InvalidParamException(TRACE_INFO,
			"LGParseLink: Invalid outgoing set at 1; expecting LgDictNode");

	if (3 <= _outgoing.size() and
	   NUMBER_NODE != _outgoing[2]->get_type())
		throw InvalidParamException(TRACE_INFO,
			"LGParseLink: Invalid outgoing set at 2; expecting NumberNode");

	if (4 <= _outgoing.size() and
	   ATOM_SPACE != _outgoing[3]->get_type())
		throw InvalidParamException(TRACE_INFO,
			"LGParseLink: Invalid outgoing set at 3; expecting AtomSpace");

	if (5 <= _outgoing.size() and
	   not nameserver().isA(_outgoing[4]->get_type(), STORAGE_NODE))
		throw InvalidParamException(TRACE_INFO,
			"LGParseLink: Invalid outgoing set at 4; expecting StorageNode");

	// Link grammar, for some reason, has a different error handler
	// per thread. Don't know why. So we have to set it every time,
	// because we don't know what thread we are in.
	lg_error_set_handler(error_handler, nullptr);

#if LINK_MAJOR_VERSION == 5 && LINK_MINOR_VERSION >= 11
	// Set up the dictionary config, if any.
	// This must happen before ldn->get_dictionary() because the
	// setup is stateful. This seems buggy, but is adequate for now.
	// XXX FIXME. This should be part of the LgDictNode but since
	// LgDictNode is a node, not a link, its hard to pass args.
	// We would need to wrap it with a StateLink, or maybe use the
	// new-fangled "sensory API". Sheesh.
	if (4 <= _outgoing.size())
	{
		AtomSpacePtr asp = AtomSpaceCast(_outgoing[3]);
		StorageNodePtr stnp;
		if (5 <= _outgoing.size())
			stnp = StorageNodeCast(_outgoing[4]);

		lg_config_atomspace(asp, stnp);
	}
#endif

	// Get the dictionary
	LgDictNodePtr ldn(LgDictNodeCast(_outgoing[1]));
	Dictionary dict = ldn->get_dictionary();
	if (nullptr == dict)
		throw InvalidParamException(TRACE_INFO,
			"LgParseLink requires valid dictionary! \"%s\" was given.",
			ldn->get_name().c_str());

	// Set up the sentence. Several forms are supported:
	// 1) Hard-coded as (PhraseNode "Some sentence to parse")
	// 2) Some executable atom that returns a Node or StringValue
	// 3) Some executable atom that returns a stream of strings.
	//    This third case is interesting but experimental. Might be
	//    buggy.
	ValuePtr phrsv(_outgoing[0]);
	if (_outgoing[0]->is_executable())
	{
		phrsv = _outgoing[0]->execute(as, silent);
		if (phrsv->is_type(LINK_VALUE))
		{
			// For now, only one at a time!?
			const ValueSeq& vlist = LinkValueCast(phrsv)->value();
			if (1 != vlist.size())
				throw InvalidParamException(TRACE_INFO,
					"LGParseLink: Expecting Value of length one");
			phrsv = vlist[0];
		}
	}

	const char* phrstr = nullptr;
	if (phrsv->is_type(NODE))
		phrstr = HandleCast(phrsv)->get_name().c_str();
	else
	if (phrsv->is_type(STRING_VALUE))
	{
		const std::vector<std::string>& sli = StringValueCast(phrsv)->value();
		if (1 != sli.size())
			throw InvalidParamException(TRACE_INFO,
				"LGParseLink: Expecting Value of length one");
		phrstr = sli[0].c_str();
	}
	else
		throw InvalidParamException(TRACE_INFO,
			"LGParseLink: Expecting Node or StringValue, got %s",
			phrsv->to_string().c_str());

	// Now, actually parse.
	Sentence sent = sentence_create(phrstr, dict);
	if (nullptr == sent)
		throw FatalErrorException(TRACE_INFO,
			"LGParseLink: Unexpected parser failure!");

	// Work with the default parse options (mostly).
	// Suppress printing of combinatorial-overflow warning.
	// Set timeout to 150 seconds; the default is infinite.
#define MAX_PARSE_TIME 150
	Parse_Options opts = parse_options_create();

	// Set to 0 to disable all messages (including warnings).
	// Set to 1 to get basic info and warnings.
	// Set to 2 to get timing info.
	// Set to 6 to get pruning/power-pruning info.
	// We want 0 here, because otherwise the log fills up with
	// [WARN] Combinatorial explosion! messages. Yuck.
	parse_options_set_verbosity(opts, 0);
	parse_options_set_max_parse_time(opts, MAX_PARSE_TIME);

	// For the MST/MPG parses, the disjuncts consist of all-optional
	// connectors, and the number of parses generated is huge. If we
	// expect to have a good chance of finding the linkage with the
	// minimal cost, we have to look at a lot of them. This does
	// impact performance; I don't know how much. Storage is about
	// 120 bytes per linkage, so 15000 linkages == 2MBytes.
#define DEFAULT_NUM_LINKAGES 15000
	parse_options_set_linkage_limit(opts, DEFAULT_NUM_LINKAGES);

	// For the ANY language, this code is being used for sampling.
	// In this case, we are not concerned about reproducibility,
	// but want different, truly random results each time through.
	// Viz, every time we have a four-word sentence, we want a
	// different parse for it, each time. Bug #3065.
	parse_options_set_repeatable_rand(opts, 0);

	// The number of linkages to process.
	int max_linkages = 0;
	if (3 <= _outgoing.size())
	{
		NumberNodePtr nnp(NumberNodeCast(_outgoing[2]));
		max_linkages = nnp->get_value() + 0.5;

		if (DEFAULT_NUM_LINKAGES < max_linkages)
			parse_options_set_linkage_limit(opts, max_linkages);
	}

	// XXX FIXME -- We should fish parse options out of the atomspace.
	// Something like this, maybe:
	//     EvaluationLink
	//         PredicateNode "LG ParseTime"
	//         ListLink
	//             LgDictNode "en"
	//             NumberNode 42
	// ... or something like that ... or maybe Values on the DictNode?

	// Avoid generating big piles of Atoms, if the user did not
	// want them. (The extra Atoms describe disjuncts, etc.)
	bool minimal = (get_type() == LG_PARSE_MINIMAL);
	bool djonly = (get_type() == LG_PARSE_DISJUNCTS);
	bool sectonly = (get_type() == LG_PARSE_SECTIONS);
	bool bondonly = (get_type() == LG_PARSE_BONDS);

	// Count the number of parses.
	int num_linkages = sentence_parse(sent, opts);
	if (num_linkages < 0)
	{
		sentence_delete(sent);
		parse_options_delete(opts);
		lg_error_flush();
		lg_error_clearall();

		// Sentence too long.
		if (-2 == num_linkages)
			throw RuntimeException(TRACE_INFO,
				"LGParseLink: Sentence too long >>%s<<", phrstr);

		// Attempting to parse pure whitespace will return -1. e.g.
		//   (LgParseBonds (Phrase "\n\n\n\n\n") (LgDict "any") (Number 4))
		// LG sentence_split() returned non-zero value.
		// In this case, there really are no parses.

		// Empty LinkValue for those guys expecting LinkValue
		if (sectonly or bondonly or djonly)
			return createLinkValue();

		// Bogus SentenceNode. This might make downstream choke!?
		char idstr[37];
		uuid_unparse(0, idstr);
		char sentstr[47] = "sentence@";
		strcat(sentstr, idstr);
		return as->add_node(SENTENCE_NODE, sentstr);
	}

	// If num_links is zero, try again, allowing null linked words.
	// But only if there were really zero, and not a timeout.
	if (num_linkages == 0 and not parse_options_resources_exhausted(opts))
	{
		parse_options_reset_resources(opts);
		parse_options_set_min_null_count(opts, 1);
		parse_options_set_max_null_count(opts, sentence_length(sent));
		num_linkages = sentence_parse(sent, opts);
	}

	if (num_linkages <= 0)
	{
		sentence_delete(sent);
		parse_options_delete(opts);
		lg_error_flush();
		lg_error_clearall();
		throw RuntimeException(TRACE_INFO,
			"LGParseLink: Parser timeout. (%d)", num_linkages);
	}

	// Post-processor might not accept all of the parses.
	num_linkages = sentence_num_valid_linkages(sent);

	// Clamp number of parses to placed in AtomSpace to be no more
	// than what was asked for.
	if ((max_linkages > 0) && (max_linkages < num_linkages))
		num_linkages = max_linkages;

	// Create the SentenceNode only for the old-style output
	Handle snode;
	char sentstr[47] = "sentence@";
	if (not (sectonly or bondonly or djonly))
	{
		// Hmm. I hope that uuid_generate() won't block if there is not
		// enough entropy in the entropy pool....
		uuid_t uu;
		uuid_generate(uu);
		char idstr[37];
		uuid_unparse(uu, idstr);
		strcat(sentstr, idstr);

		snode = as->add_node(SENTENCE_NODE, sentstr);
	}

	// There are only so many parses available.
	int num_available = sentence_num_linkages_post_processed(sent);

	ValueSeq vlist;
	int jct = 0;
	for (int i=0; jct<num_linkages and i<num_available; i++)
	{
		// Skip sentences with P.P. violations.
		if (0 < sentence_num_violations(sent, i)) continue;
		jct ++;
		Linkage lkg = linkage_create(i, sent, opts);
		if (sectonly)
		{
			ValuePtr sects(make_sects(lkg, phrstr, as));
			ValuePtr bonds(make_bonds(lkg, phrstr, as));
			vlist.emplace_back(createLinkValue(ValueSeq({sects, bonds})));
		}
		else if (bondonly)
		{
			ValuePtr words(make_words(lkg, phrstr, as));
			ValuePtr bonds(make_bonds(lkg, phrstr, as));
			vlist.emplace_back(createLinkValue(ValueSeq({words, bonds})));
		}
		else if (djonly)
		{
			vlist.emplace_back(make_djs(lkg, phrstr, as));
		}
		else
		{
			Handle pnode = cvt_linkage(lkg, i, sentstr, phrstr, minimal, as);
			as->add_link(PARSE_LINK, pnode, snode);
		}
		linkage_delete(lkg);
	}

	sentence_delete(sent);
	parse_options_delete(opts);
	lg_error_flush();
	lg_error_clearall();

	// Return a LinkValue holding all of the disjuncts
	if (sectonly or bondonly or djonly)
		return createLinkValue(vlist);

	return snode;
}

static std::atomic<unsigned long> wcnt;

// Take a single linkage, and stuff it into the AtomSpace.
Handle LGParseLink::cvt_linkage(Linkage lkg, int i, const char* idstr,
                                const char* phrstr,
                                bool minimal, AtomSpace* as) const
{
	std::string parseid = idstr;
	parseid += "_parse_";
	parseid += std::to_string(i);
	Handle pnode(as->add_node(PARSE_NODE, std::move(parseid)));

	// Loop over all the words.
	HandleSeq wrds;
	int nwords = linkage_get_num_words(lkg);
	for (int w=0; w<nwords; w++)
	{
		// Generate a unique UUID for that word.
		uuid_t uu2;
		uuid_generate(uu2);
		char idstr2[37];
		uuid_unparse(uu2, idstr2);

		// Get the word in the sentence.
		std::string wrd = get_word_string(lkg, w, phrstr);
		std::string buff = wrd;
		buff += "@";
		buff += idstr2;
		Handle winst(as->add_node(WORD_INSTANCE_NODE, std::move(buff)));
		wrds.push_back(winst);

		// Associate the word with the parse.
		as->add_link(WORD_INSTANCE_LINK, winst, pnode);
		as->add_link(REFERENCE_LINK, winst,
			as->add_node(WORD_NODE, std::move(wrd)));
		as->add_link(WORD_SEQUENCE_LINK, winst,
			Handle(createNumberNode(++wcnt)));

		// Don't bother with disjuncts for the minimal parses.
		if (minimal) continue;

		// Convert the disjunct to atomese.
		HandleSeq conseq = make_lg_conseq(lkg, w, as);

		if (0 == conseq.size()) continue;

		// Set up the disjuncts on each word
		as->add_link(LG_WORD_CSET, winst,
			as->add_link(LG_AND, std::move(conseq)));
	}

	// Loop over all the links
	int nlinks = linkage_get_num_links(lkg);
	for (int lk=0; lk<nlinks; lk++)
	{
		int lword = linkage_get_link_lword(lkg, lk);
		int rword = linkage_get_link_rword(lkg, lk);
		Handle lst(as->add_link(LIST_LINK, wrds[lword], wrds[rword]));

		// The link
		const char* label = linkage_get_link_label(lkg, lk);
		Handle lrel(as->add_node(LG_LINK_NODE, label));
		as->add_link(EVALUATION_LINK, lrel, lst);

		// Don't bother with the link instances for the minimal parse.
		if (minimal) continue;

		// The link instance.
		std::string buff = label;
		buff += "@";
		buff += parseid;
		buff += "-link-";
		buff += std::to_string(lk);
		Handle linst(as->add_node(LG_LINK_INSTANCE_NODE, std::move(buff)));
		as->add_link(EVALUATION_LINK, linst, lst);

		// The relation between link and link instance
		as->add_link(REFERENCE_LINK, linst, lrel);

		// The connectors for the link instance.
		const char* llab = linkage_get_link_llabel(lkg, lk);
		const char* rlab = linkage_get_link_rlabel(lkg, lk);
		as->add_link(LG_LINK_INSTANCE_LINK,
			linst,
			as->add_link(LG_CONNECTOR,
				as->add_node(LG_CONN_NODE, llab),
				as->add_node(LG_CONN_DIR_NODE, "+")),
			as->add_link(LG_CONNECTOR,
				as->add_node(LG_CONN_NODE, rlab),
				as->add_node(LG_CONN_DIR_NODE, "-")));
	}

	return pnode;
}

// Create only the disjuncts for the parse, and nothing else.
ValuePtr LGParseLink::make_djs(Linkage lkg, const char* phrstr,
                               AtomSpace* as) const
{
	HandleSeq djs;

	// Loop over all the words.
	int nwords = linkage_get_num_words(lkg);
	for (int w=0; w<nwords; w++)
	{
		HandleSeq conseq = make_lg_conseq(lkg, w, as);
		if (0 == conseq.size()) continue;

		std::string wrd = get_word_string(lkg, w, phrstr);

		// Set up the disjuncts on each word
		Handle dj = as->add_link(LG_DISJUNCT,
			as->add_node(WORD_NODE, std::move(wrd)),
			as->add_link(LG_AND, std::move(conseq)));

		djs.emplace_back(dj);
	}
	return createLinkValue(djs);
}

// Create only the Sections for the parse, and nothing else.
// Sections are almost exactly like Disjuncts, but have a
// different format.
ValuePtr LGParseLink::make_sects(Linkage lkg, const char* phrstr,
                                 AtomSpace* as) const
{
	HandleSeq djs;

	// Loop over all the words.
	int nwords = linkage_get_num_words(lkg);
	for (int w=0; w<nwords; w++)
	{
		HandleSeq conseq = make_conseq(lkg, w, phrstr, as);
		if (0 == conseq.size()) continue;

		std::string wrd = get_word_string(lkg, w, phrstr);

		// Set up the disjuncts on each word
		Handle dj = as->add_link(SECTION,
			as->add_node(WORD_NODE, std::move(wrd)),
			as->add_link(CONNECTOR_SEQ, std::move(conseq)));

		djs.emplace_back(dj);
	}

	return createLinkValue(djs);
}

// Create only the EdgeLink-BondNodes for the parse.
// These are just the links in the linkage.
ValuePtr LGParseLink::make_bonds(Linkage lkg, const char* phrstr,
                                 AtomSpace* as) const
{
	HandleSeq bonds;

	// Loop over all the links.
	int nlinks = linkage_get_num_links(lkg);
	for (int lk=0; lk<nlinks; lk++)
	{
		int lword = linkage_get_link_lword(lkg, lk);
		int rword = linkage_get_link_rword(lkg, lk);

		// Get the words at either end.
		Handle lst(as->add_link(LIST_LINK,
			as->add_node(WORD_NODE, get_word_string(lkg, lword, phrstr)),
			as->add_node(WORD_NODE, get_word_string(lkg, rword, phrstr))));

		// The bond type.
		const char* label = linkage_get_link_label(lkg, lk);
		Handle brel(as->add_node(BOND_NODE, label));

		Handle bond(as->add_link(EDGE_LINK, brel, lst));
		bonds.emplace_back(bond);
	}
	return createLinkValue(bonds);
}

ValuePtr LGParseLink::make_words(Linkage lkg, const char* phrstr,
                                 AtomSpace* as) const
{
	// Loop over all the words.
	HandleSeq words;
	int nwords = linkage_get_num_words(lkg);
	for (int w=0; w<nwords; w++)
	{
		// Get the word in the sentence.
		std::string wrd = get_word_string(lkg, w, phrstr);
		Handle word(as->add_node(WORD_NODE, std::move(wrd)));
		words.emplace_back(word);
	}
	return createLinkValue(words);
}

/// Convert the disjunct to LG-style Atomese, using LgConn and LgConDir.
HandleSeq LGParseLink::make_lg_conseq(Linkage lkg, int w, AtomSpace* as) const
{
	// This requires parsing a string. Fortunately, the
	// string is a very simple format.
	const char* djstr = linkage_get_disjunct_str(lkg, w);

	HandleSeq conseq;
	const char* p = djstr;
	while (*p)
	{
		while (' ' == *p) p++;
		if (0 == *p) break;
		bool multi = false;
		if ('@' == *p) { multi = true; p++; }
		const char* s = strchr(p, ' ');
		size_t len = s-p-1;
		if (NULL == s) len = strlen(p) - 1;
		char cstr[60];
		if (60 <= len)
			throw RuntimeException(TRACE_INFO,
				"LGParseLink: Dictionary has a bug; Unexpectedly long connector=%s", djstr);
		strncpy(cstr, p, len);
		cstr[len] = 0;
		Handle con(as->add_node(LG_CONN_NODE, cstr));
		cstr[0] = *(p+len);
		cstr[1] = 0;
		Handle dir(as->add_node(LG_CONN_DIR_NODE, cstr));
		p = p+len+1;

		HandleSeq cono;
		cono.push_back(con);
		cono.push_back(dir);
		if (multi)
		{
			Handle mu(as->add_node(LG_CONN_MULTI_NODE, "@"));
			cono.push_back(mu);
		}
		Handle conl(as->add_link(LG_CONNECTOR, std::move(cono)));
		conseq.push_back(conl);
	}

	return conseq;
}

/// Convert the disjunct to Section-style Atomese, using ConnectorLink
/// and ConnectorDir. Similar to `make_lg_conseq` except that this uses
/// the generic connector style, and uses words, not link types, for the
/// connectors.
HandleSeq LGParseLink::make_conseq(Linkage lkg, int w,
                                   const char* phrstr,
                                   AtomSpace* as) const
{
	std::vector<int> lks;

	// Loop over all links, find the ones which connect to this word.
	size_t nlinks = linkage_get_num_links(lkg);
	for (size_t li=0; li < nlinks; li++)
	{
		// Look for links attaching to this word.
		int lw = (int) linkage_get_link_lword(lkg, li);
		int rw = (int) linkage_get_link_rword(lkg, li);

		if (lw == w) lks.push_back(rw);
		else if (rw == w) lks.push_back(lw);
	}

	// Place them in ascending order.
	std::sort(lks.begin(), lks.end());

	// Create a connector seq from the sorted links
	HandleSeq conseq;
	for (int c : lks)
	{
		std::string wrd = get_word_string(lkg, c, phrstr);
		Handle con(as->add_node(WORD_NODE, std::move(wrd)));
		Handle dir(as->add_node(SEX_NODE, c<w ? "-" : "+"));
		Handle conl(as->add_link(CONNECTOR, con, dir));
		conseq.push_back(conl);
	}

	return conseq;
}

std::string LGParseLink::get_word_string(Linkage lkg, int w,
                                         const char* phrstr) const
{
	size_t sb = linkage_get_word_byte_start(lkg, w);
	size_t eb = linkage_get_word_byte_end(lkg, w);

	// Problem: the default LG API supplies the word together with
	// the subscript, and with word regex and guess-marks. We really
	// do NOT want that crud. So use the byte offsets to get the
	// actual original string.  Since LEFT-WALL and RIGHT-WALL have
	// no offsets, we need to handle those differently.
	if (eb != sb) // Neither are equal to -1
	{
		std::string rv(phrstr + sb, eb - sb);
		return rv;
	}

	const char* wrd = linkage_get_word(lkg, w);

	// LEFT-WALL is not an ordinary word. Its special. Make it
	// extra-special by adding "illegal" punctuation to it.
	// FYI, this is compatible with Relex, relex2logic.
	if (0 == w and 0 == strcmp(wrd, "LEFT-WALL"))
		return "###LEFT-WALL###";

	int nwords = linkage_get_num_words(lkg);
	if (nwords-1 == w and 0 == strcmp(wrd, "RIGHT-WALL"))
		return "###RIGHT-WALL###";

	return wrd;
}

DEFINE_LINK_FACTORY(LGParseLink, LG_PARSE_LINK)

/* ===================== END OF FILE ===================== */
