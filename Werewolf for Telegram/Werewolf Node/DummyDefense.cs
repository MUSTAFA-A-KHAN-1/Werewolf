using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Werewolf_Node.Helpers;
using Werewolf_Node.Models;

namespace Werewolf_Node
{
    public partial class Werewolf
    {
        private void SendDummyDefenseStatements()
        {
            if (Players == null) return;

            var dummies = Players.Where(x => x.IsDummy && !x.IsDead).ToList();
            if (!dummies.Any()) return;

            foreach (var dummy in dummies.OrderBy(x => Program.R.Next()).Take(Math.Min(dummies.Count, 2)))
            {
                var statement = CreateDummyAIDefenseStatement(dummy);
                if (string.IsNullOrWhiteSpace(statement))
                    continue;

                SendWithQueue(statement);
                Thread.Sleep(500);
            }
        }

        private string CreateDummyAIDefenseStatement(IPlayer dummy)
        {
            if (dummy == null) return null;
            var name = dummy.GetName(menu: true).FormatHTML();
            var isBadRole = WolfRoles.Contains(dummy.PlayerRole)
                            || dummy.PlayerRole == IRole.SerialKiller
                            || dummy.PlayerRole == IRole.Zombie
                            || dummy.PlayerRole == IRole.Arsonist
                            || dummy.PlayerRole == IRole.BloodReaper
                            || dummy.PlayerRole == IRole.SnowWolf;

            var suspect = Players.Where(x => !x.IsDead && x.Id != dummy.Id).OrderBy(x => Program.R.Next()).FirstOrDefault();
            var suspectName = suspect != null ? suspect.GetName(menu: true).FormatHTML() : "someone";

            var templates = new List<string>();

            if (isBadRole)
            {
                templates.AddRange(new[]
                {
                    $"{name} says: \"I'm safe. Don't lynch me, I'm not the wolf.\"",
                    $"{name} says: \"Trust me, I'm innocent. If you kill me, you'll regret it.\"",
                    $"{name} says: \"I think {suspectName} is lying, not me.\"",
                    $"{name} says: \"I'm telling the truth. I'm safe.\"",
                    $"{name} says: \"Don't trust {suspectName}. They're the suspicious one.\""
                });
            }
            else
            {
                templates.AddRange(new[]
                {
                    $"{name} says: \"I'm safe. I'm a normal villager. Don't vote for me.\"",
                    $"{name} says: \"I feel fine. I'm not a wolf.\"",
                    $"{name} says: \"I think {suspectName} is acting suspicious.\"",
                    $"{name} says: \"I'm telling the truth. I'm innocent.\"",
                    $"{name} says: \"Please don't lynch me. I'm safe.\""
                });
            }

            return templates[Program.R.Next(templates.Count)];
        }
    }
}
