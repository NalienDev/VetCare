package util;

import java.util.*;

public class EspeciesRacas {
    
    private static final Map<String, List<String>> ESPECIES_RACAS = new LinkedHashMap<>();
    
    static {
        // CÃO
        List<String> racasCao = Arrays.asList(
            "Labrador Retriever", "Golden Retriever", "Pastor Alemão", "Bulldog Francês",
            "Bulldog Inglês", "Beagle", "Poodle", "Rottweiler", "Yorkshire Terrier",
            "Boxer", "Dachshund (Salsicha)", "Husky Siberiano", "Doberman", "Shih Tzu",
            "Pug", "Chihuahua", "Border Collie", "Cocker Spaniel", "Springer Spaniel",
            "Dálmata", "Schnauzer", "Bernese Mountain Dog", "Akita", "Chow Chow",
            "Mastim", "São Bernardo", "Bull Terrier", "Staffordshire", "Jack Russell Terrier",
            "Bichon Frisé", "Maltês", "West Highland Terrier", "Lhasa Apso", "Basenji",
            "Pointer", "Setter Irlandês", "Setter Inglês", "Weimaraner", "Vizsla",
            "Basset Hound", "Bloodhound", "Galgo", "Whippet", "Greyhound",
            "Border Terrier", "Cairn Terrier", "Scottish Terrier", "Shar Pei",
            "Cão de Água Português", "Rafeiro Alentejano", "Perdigueiro Português",
            "Podengo Português", "Castro Laboreiro", "Serra da Estrela",
            "Mestiço", "SRD (Sem Raça Definida)"
        );
        ESPECIES_RACAS.put("Cão", racasCao);
        
        // GATO
        List<String> racasGato = Arrays.asList(
            "Persa", "Siamês", "Maine Coon", "Ragdoll", "Bengal", "British Shorthair",
            "Abissínio", "Sphynx", "Scottish Fold", "Birmanês", "Norueguês da Floresta",
            "Angorá", "Russian Blue", "Exótico", "Oriental", "Manx", "Devon Rex",
            "Cornish Rex", "Burmês", "Tonkinês", "Chartreux", "Balinês", "Somali",
            "Bombaim", "Havana Brown", "Singapura", "Korat", "LaPerm", "Selkirk Rex",
            "American Shorthair", "American Curl", "Munchkin", "Savannah", "Toyger",
            "Europeu Comum", "Mestiço", "SRD (Sem Raça Definida)"
        );
        ESPECIES_RACAS.put("Gato", racasGato);
        
        // COELHO
        List<String> racasCoelho = Arrays.asList(
            "Coelho Anão", "Mini Lop", "Holland Lop", "Lionhead", "Rex",
            "Angorá", "Gigante Flamengo", "Nova Zelândia", "Californiano",
            "Netherland Dwarf", "Jersey Wooly", "Fuzzy Lop", "English Lop",
            "French Lop", "Himalaia", "Hotot", "Mini Rex", "Polish",
            "Mestiço"
        );
        ESPECIES_RACAS.put("Coelho", racasCoelho);
        
        // PORQUINHO DA ÍNDIA
        List<String> racasPorquinho = Arrays.asList(
            "Americano", "Abissínio", "Peruano", "Silkie", "Texel",
            "Coronet", "Teddy", "Rex", "Skinny Pig", "Baldwin",
            "Alpaca", "Lunkarya", "Mestiço"
        );
        ESPECIES_RACAS.put("Porquinho da Índia", racasPorquinho);
        
        // HAMSTER
        List<String> racasHamster = Arrays.asList(
            "Sírio (Dourado)", "Anão Russo", "Roborovski", "Chinês",
            "Anão de Campbell", "Anão Winter White", "Mestiço"
        );
        ESPECIES_RACAS.put("Hamster", racasHamster);
        
        // CAVALO
        List<String> racasCavalo = Arrays.asList(
            "Puro Sangue Inglês", "Quarto de Milha", "Árabe", "Appaloosa",
            "Paint Horse", "Andaluz", "Lusitano", "Frisão", "Hannoveriano",
            "Holsteiner", "Oldenburg", "Westfalen", "Sela Francesa",
            "Puro Sangue Árabe", "Morgan", "Tennessee Walker", "Mustang",
            "Clydesdale", "Shire", "Percheron", "Haflinger", "Islandês",
            "Fjord", "Connemara", "Welsh Pony", "Shetland", "Alter Real",
            "Garrano", "Sorraia", "Mestiço"
        );
        ESPECIES_RACAS.put("Cavalo", racasCavalo);
        
        // PÁSSARO
        List<String> racasPassaro = Arrays.asList(
            "Periquito Australiano", "Calopsita", "Agapornis", "Canário",
            "Papagaio Cinzento", "Papagaio Amazona", "Cacatua", "Arara",
            "Diamante Mandarim", "Diamante de Gould", "Manon", "Periquito Inglês",
            "Ring Neck", "Rosela", "Eclectus", "Pionus", "Louro", "Jandaia",
            "Mestiço"
        );
        ESPECIES_RACAS.put("Pássaro", racasPassaro);
        
        // TARTARUGA
        List<String> racasTartaruga = Arrays.asList(
            "Tartaruga de Orelha Vermelha", "Tartaruga de Caixa", "Tartaruga Pintada",
            "Tartaruga Musk", "Tartaruga Cumberland", "Jabuti Piranga",
            "Jabuti Tinga", "Tartaruga Leopardo", "Tartaruga Grega",
            "Tartaruga Hermann", "Tartaruga Russa", "Mestiço"
        );
        ESPECIES_RACAS.put("Tartaruga", racasTartaruga);
        
        // FURÃO
        List<String> racasFurao = Arrays.asList(
            "Furão Standard", "Furão Angora", "Furão Albino",
            "Furão Sable", "Furão Panda", "Mestiço"
        );
        ESPECIES_RACAS.put("Furão", racasFurao);
        
        // CHINCHILA
        List<String> racasChinchila = Arrays.asList(
            "Chinchila Standard", "Chinchila Branca", "Chinchila Velvet",
            "Chinchila Violet", "Chinchila Beige", "Mestiço"
        );
        ESPECIES_RACAS.put("Chinchila", racasChinchila);
    }
    
    public static Map<String, List<String>> getTodasEspeciesRacas() {
        return new LinkedHashMap<>(ESPECIES_RACAS);
    }
    
    public static List<String> getRacasPorEspecie(String especie) {
        return ESPECIES_RACAS.getOrDefault(especie, new ArrayList<>());
    }
    
    public static Set<String> getTodasEspecies() {
        return ESPECIES_RACAS.keySet();
    }
}