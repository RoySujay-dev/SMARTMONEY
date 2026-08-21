using System.Text.RegularExpressions;

namespace SmartMoney.Infrastructure.Persistence.Repositories;

/// <summary>
/// Builds the pattern used by catalogue search.
/// </summary>
/// <remarks>
/// Search matches where the term starts a word, not anywhere inside one. A
/// plain <c>ILIKE '%term%'</c> made short queries behave backwards: "st"
/// matched "lifeSTyle" and "ReSTaurants" while the longer, more deliberate
/// "stores" matched nothing, so typing more felt like falling off a cliff
/// instead of narrowing the list.
/// </remarks>
internal static class SearchPattern
{
    /// <summary>
    /// A PostgreSQL regex matching <paramref name="searchTerm"/> at the start
    /// of any word. Pair it with <see cref="RegexOptions.IgnoreCase"/> so
    /// Npgsql emits the case-insensitive <c>~*</c> operator.
    /// </summary>
    /// <remarks>
    /// <c>\m</c> is PostgreSQL's start-of-word anchor. Word characters there
    /// are alphanumerics and underscore, so a hyphen counts as a boundary and
    /// "cliq" still finds the slug "tata-cliq".
    ///
    /// The term is escaped, which also closes a hole in the old LIKE patterns:
    /// they interpolated raw input, so a query of "%" matched every row and
    /// returned the whole active catalogue in one unauthenticated request.
    /// </remarks>
    public static string WordPrefix(string searchTerm)
    {
        return @"\m" + Regex.Escape(searchTerm.Trim());
    }
}
