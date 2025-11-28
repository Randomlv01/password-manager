import os
import encoding.base64

struct PasswordManager {
    mut:
    storage map[string]string
    file    string
}

fn new_manager(file string) PasswordManager {
    mut pm := PasswordManager{
        storage: map[string]string{}
        file: file
    }
    pm.load()
    return pm
}

fn (mut pm PasswordManager) load() {
    if !os.exists(pm.file) {
        return
    }
    data := os.read_file(pm.file) or { return }
    for line in data.split_into_lines() {
        parts := line.split(':')
        if parts.len == 2 {
            pm.storage[parts[0]] = parts[1]
        }
    }
}

fn (mut pm PasswordManager) save() {
    mut lines := []string{}
    for key, val in pm.storage {
        lines << '$key:$val'
    }
    os.write_file(pm.file, lines.join('\n')) or {}
}

fn (mut pm PasswordManager) add(key string, password string) {
    encoded := base64.encode(password.bytes())
    pm.storage[key] = encoded
    pm.save()
    println('Gespeichert: $key')
}

fn (pm &PasswordManager) get(key string) {
    encoded := pm.storage[key] or { '' }
    if encoded == '' {
        println('Nicht gefunden!')
        return
    }
    decoded := base64.decode(encoded).bytestr()
    println('Passwort für $key: $decoded')
}

fn (mut pm PasswordManager) delete(key string) {
    if key in pm.storage {
        pm.storage.delete(key)
        pm.save()
        println('Gelöscht: $key')
    } else {
        println('Nicht gefunden: $key')
    }
}

fn main() {
    mut pm := new_manager('passwords.db')

    for {
        println('\n--- Passwort Manager ---')
        println('1) Passwort hinzufügen')
        println('2) Passwort abrufen')
        println('3) Passwort löschen')
        println('4) Beenden')
        print('> ')
        choice := os.get_line().trim_space()

        match choice {
            '1' {
                print('Name/Schlüssel: ')
                key := os.get_line().trim_space()
                print('Passwort: ')
                password := os.get_line().trim_space()
                pm.add(key, password)
            }
            '2' {
                print('Name/Schlüssel: ')
                key := os.get_line().trim_space()
                pm.get(key)
            }
            '3' {
                print('Name/Schlüssel: ')
                key := os.get_line().trim_space()
                pm.delete(key)
            }
            '4' {
                println('Beende...')
                break
            }
            else {
                println('Ungültige Auswahl')
            }
        }
    }
}
