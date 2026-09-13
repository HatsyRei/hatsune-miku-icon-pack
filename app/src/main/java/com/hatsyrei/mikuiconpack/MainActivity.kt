package com.hatsyrei.mikuiconpack

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import org.xmlpull.v1.XmlPullParser

/**
 * Entry point for every launcher theme intent declared in the manifest.
 *
 * Launched normally it shows the pack contents and how to apply it. Launched
 * for a result — which is how launchers run their "pick an icon" flow — tapping
 * an icon hands it back as an [Intent.ShortcutIconResource].
 */
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val pickMode = callingActivity != null
        val icons = loadIconEntries()

        setContent {
            MikuIconPackTheme {
                Surface(
                    color = MaterialTheme.colorScheme.background,
                    modifier = Modifier.fillMaxSize(),
                ) {
                    IconGrid(
                        icons = icons,
                        pickMode = pickMode,
                        onPick = ::returnIcon,
                    )
                }
            }
        }
    }

    @SuppressLint("DiscouragedApi")
    private fun returnIcon(name: String) {
        val id = resources.getIdentifier(name, "drawable", packageName)
        if (id == 0) return
        val icon = Intent.ShortcutIconResource.fromContext(this, id)
        setResult(RESULT_OK, Intent().putExtra(Intent.EXTRA_SHORTCUT_ICON_RESOURCE, icon))
        finish()
    }

    /**
     * Reads the same drawable.xml that launchers read, so the in-app grid can
     * never drift from what the pack advertises.
     */
    private fun loadIconEntries(): List<IconEntry> {
        val parser = resources.getXml(R.xml.drawable)
        val entries = mutableListOf<IconEntry>()
        try {
            var category: String? = null
            while (parser.next() != XmlPullParser.END_DOCUMENT) {
                if (parser.eventType != XmlPullParser.START_TAG) continue
                when (parser.name) {
                    // Attributes in res/xml resources carry no namespace.
                    "category" -> category = parser.getAttributeValue(null, "title")
                    "item" -> parser.getAttributeValue(null, "drawable")?.let {
                        entries += IconEntry(it, category)
                    }
                }
            }
        } finally {
            parser.close()
        }
        return entries
    }
}

private data class IconEntry(val drawable: String, val category: String?)

@Composable
private fun MikuIconPackTheme(content: @Composable () -> Unit) {
    val teal = Color(0xFF39C5BB)
    MaterialTheme(
        colorScheme = darkColorScheme(primary = teal, secondary = teal),
        content = content,
    )
}

@Composable
private fun IconGrid(
    icons: List<IconEntry>,
    pickMode: Boolean,
    onPick: (String) -> Unit,
) {
    LazyVerticalGrid(
        columns = GridCells.Fixed(4),
        contentPadding = PaddingValues(16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        item(span = { GridItemSpan(maxLineSpan) }) {
            Header(count = icons.size, pickMode = pickMode)
        }
        items(icons, key = { it.drawable }) { entry ->
            IconCell(entry = entry, onClick = { onPick(entry.drawable) })
        }
    }
}

@Composable
private fun Header(count: Int, pickMode: Boolean) {
    Column(modifier = Modifier.padding(bottom = 8.dp)) {
        Text(
            text = stringResource(if (pickMode) R.string.pick_title else R.string.app_name),
            style = MaterialTheme.typography.headlineSmall,
        )
        Text(
            text = stringResource(R.string.pack_subtitle, count),
            style = MaterialTheme.typography.bodyMedium,
        )
        if (!pickMode) {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 16.dp),
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = stringResource(R.string.howto_title),
                        style = MaterialTheme.typography.titleMedium,
                    )
                    Text(
                        text = stringResource(R.string.howto_body),
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(top = 8.dp),
                    )
                }
            }
        }
    }
}

@SuppressLint("DiscouragedApi")
@Composable
private fun IconCell(entry: IconEntry, onClick: () -> Unit) {
    val context = LocalContext.current
    val id = remember(entry.drawable) {
        context.resources.getIdentifier(entry.drawable, "drawable", context.packageName)
    }
    if (id == 0) return
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.fillMaxWidth(),
    ) {
        Image(
            painter = painterResource(id),
            contentDescription = stringResource(R.string.icon_content_description, entry.drawable),
            modifier = Modifier
                .size(64.dp)
                .clickable(onClick = onClick),
        )
        Text(
            text = entry.drawable,
            style = MaterialTheme.typography.labelSmall,
            maxLines = 1,
        )
    }
}
