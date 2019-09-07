module providers;

import std.stdio;
import std.net.curl: get, HTTP;
import std.string: format;
import std.json: parseJSON;
import painlessjson: fromJSON;
import config: ConfigGroup;

TaskProvider getTaskProvider(ConfigGroup config) {
    switch (config.key) {
        case "trello":
            return new TrelloTaskProvider(
                config.settings["apiKey"],
                config.settings["apiToken"],
                config.settings["boardId"]
            );
        default:
            writeln("Cannot resolve config key %s", config.key);
            return null;
    }
}

struct CardSymbol {
    string id;
    string name;
}

struct List {
    string id;
    string name;
    CardSymbol[] cards;
}

interface TaskProvider {

    List[] getLists();
    
}

class TrelloTaskProvider : TaskProvider {

    private string key;
    private string token;
    private string boardId;

    this(string key, string token, string boardId) {
        this.key = key;
        this.token = token;
        this.boardId = boardId;
    }

    char[] get(string endpoint) {
        return get("https://api.trello.com/1/" ~ endpoint ~ format("&key=%s&token=%s", key, token));
    }
    
    override List[] getLists() {
        char[] req = this.get(format("boards/%s?fields=name,url", boardId));
        List[] list = fromJSON!(List[])(parseJSON(req));
        return list;
    }
}
