/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.
*/
pragma solidity 0.6.11;

contract RegistroImovel {
    
    struct Imovel {
        address endereco;
        string nomeProprietario;
        uint valorVenal;
    }
    
    Imovel[] public livro1;
    mapping(address => Imovel) public livro2;
    
    function registraImovel(address paramEndereco, string memory paramNomeProprietario, uint paramValorVenal) public {
        Imovel memory novoImovel = Imovel(paramEndereco, paramNomeProprietario, paramValorVenal);
        
        livro1.push(novoImovel);
        
        livro2[paramEndereco] = novoImovel;
    }
    
    function devolveNomeProprietario(uint matricula) public view returns (string memory) {
        return livro1[matricula].nomeProprietario;
    }
}
