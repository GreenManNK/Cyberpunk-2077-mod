module EquipmentEx

// Esse script roda de forma independente e estende os slots do EquipmentEx para os NPCs
// Como declaramos o módulo acima, não precisamos de nenhum "import".
class RegisterOutfitSlotsToNPCs extends ScriptableTweak {
    protected func OnApply() -> Void {
        let batch = TweakDBManager.StartBatch();
        
        // Reconhecido automaticamente graças ao "module EquipmentEx"
        let outfitSlots = OutfitConfig.OutfitSlots();
        
        // Se o EquipmentEx não tiver slots configurados ou não estiver instalado, interrompe
        if ArraySize(outfitSlots) == 0 {
            return;
        }

        // Percorre todos os registros de personagens (NPCs) no banco de dados
        for record in TweakDBInterface.GetRecords(n"Character_Record") {
            let character = record as Character_Record;
            let characterSlots = TweakDBInterface.GetForeignKeyArray(character.GetID() + t".attachmentSlots");
            
            // Segurança: Só aplica a NPCs humanoides (que possuem o slot de peito padrão)
            if ArrayContains(characterSlots, t"AttachmentSlots.Chest") {
                let modified = false;

                for outfitSlot in outfitSlots {
                    // Se o NPC ainda não tiver esse slot específico do EquipmentEx, adiciona
                    if !ArrayContains(characterSlots, outfitSlot.slotID) {
                        ArrayPush(characterSlots, outfitSlot.slotID);
                        modified = true;
                    }
                }

                // Só atualiza o banco de dados do jogo se realmente adicionou algo novo ao NPC
                if modified {
                    batch.SetFlat(character.GetID() + t".attachmentSlots", characterSlots);
                    batch.UpdateRecord(character.GetID());
                }
            }
        }

        // Aplica as alterações no TweakDB do jogo
        batch.Commit();
    }
}