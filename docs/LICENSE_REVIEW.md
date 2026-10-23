# License status and owner decision

No LICENSE file exists in the current project or reviewed Git commits. No license is selected or added by this task. A public repository/source-visible Lua does not itself express the broad reuse permissions supplied by an open-source license.

| Option | Redistribution and modification | Attribution / source | Practical tradeoff |
| --- | --- | --- | --- |
| MIT | Broad reuse, modification and redistribution allowed under its terms | Retain copyright and permission notices; no general requirement to publish modified source | Short, familiar permissive choice |
| Apache-2.0 | Broad reuse with an explicit contributor patent grant and its conditions | Preserve applicable notices/license, mark modified files, carry relevant NOTICE material; no general source-publication requirement | More detailed terms and notice work |
| Owner-approved custom source-visible terms | Could permit free use while reserving modification/redistribution permissions | Source stays readable; attribution and reuse conditions must be specified | Restrictive, not necessarily open source; requires careful wording and platform/policy review |

**Recommendation for owner review: MIT** if the goal is straightforward community reuse and maintenance. Choose Apache-2.0 if its explicit patent/notice terms are preferred. A restrictive option is available, but this report does not draft or apply one on the owner's behalf. Confirm the copyright holder, contributor rights and artwork terms before adoption.

The [MIT text](https://opensource.org/license/mit) and [Apache-2.0 text](https://www.apache.org/licenses/LICENSE-2.0) are the authoritative terms. This is a practical comparison, not a jurisdiction-specific legal conclusion.

Blizzard separately requires free distribution and visible, unobfuscated addon code and imposes other addon-use rules; a permissive software license does not override those rules. Restricting reuse does not justify hiding code. Review [Blizzard's addon policy](https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534) before release.

After owner approval: add the selected LICENSE with the correct holder/year, add NOTICE only if applicable, cover the original artwork explicitly, select the matching CurseForge license and rebuild. The packager already includes LICENSE/NOTICE when present. No-license candidate ZIP is for review; publication awaits the decision and rebuilt legal material.
